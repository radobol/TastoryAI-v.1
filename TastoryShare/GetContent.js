// GetContent.js - JavaScript preprocessor for Safari Share Extension
// This script runs in the context of the web page and extracts content for recipe processing

var ExtensionPreprocessingJS = function() {}

ExtensionPreprocessingJS.prototype = {
    run: function(completionFunction) {
    
    // Helper function to get meta tag content
    function getMetaContent(property) {
        // Try different meta tag formats
        var selectors = [
            'meta[property="' + property + '"]',
            'meta[name="' + property + '"]',
            'meta[itemprop="' + property + '"]'
        ];
        
        for (var i = 0; i < selectors.length; i++) {
            var meta = document.querySelector(selectors[i]);
            if (meta && meta.content) {
                return meta.content;
            }
        }
        return null;
    }
    
    // Helper function to normalize image URLs
    function normalizeImageURL(url) {
        if (!url) return null;
        
        // Already absolute URL
        if (url.startsWith('http://') || url.startsWith('https://')) {
            return url;
        }
        
        // Protocol-relative URL
        if (url.startsWith('//')) {
            return window.location.protocol + url;
        }
        
        // Absolute path
        if (url.startsWith('/')) {
            return window.location.origin + url;
        }
        
        // Relative path
        var base = window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1);
        return base + url;
    }
    
    // Extract image from various sources
    function extractImage() {
        console.log('Extracting image from page...');
        
        // Priority 1: Open Graph image
        var ogImage = getMetaContent('og:image');
        if (ogImage) {
            console.log('Found og:image:', ogImage);
            return normalizeImageURL(ogImage);
        }
        
        // Priority 2: Twitter image
        var twitterImage = getMetaContent('twitter:image') || getMetaContent('twitter:image:src');
        if (twitterImage) {
            console.log('Found twitter:image:', twitterImage);
            return normalizeImageURL(twitterImage);
        }
        
        // Priority 3: Schema.org JSON-LD
        var jsonLDScripts = document.querySelectorAll('script[type="application/ld+json"]');
        for (var i = 0; i < jsonLDScripts.length; i++) {
            try {
                var jsonData = JSON.parse(jsonLDScripts[i].textContent);
                if (jsonData.image) {
                    var imageUrl = typeof jsonData.image === 'string' ? 
                        jsonData.image : 
                        (jsonData.image.url || jsonData.image[0]);
                    if (imageUrl) {
                        console.log('Found JSON-LD image:', imageUrl);
                        return normalizeImageURL(imageUrl);
                    }
                }
            } catch (e) {
                console.error('Error parsing JSON-LD:', e);
            }
        }
        
        // Priority 4: Link rel="image_src"
        var imageSrcLink = document.querySelector('link[rel="image_src"]');
        if (imageSrcLink && imageSrcLink.href) {
            console.log('Found link rel=image_src:', imageSrcLink.href);
            return normalizeImageURL(imageSrcLink.href);
        }
        
        // Priority 5: First substantial image in article/main content
        var contentSelectors = ['article', 'main', '[class*="recipe"]', '[class*="content"]'];
        for (var i = 0; i < contentSelectors.length; i++) {
            var container = document.querySelector(contentSelectors[i]);
            if (container) {
                var images = container.querySelectorAll('img');
                for (var j = 0; j < images.length; j++) {
                    var img = images[j];
                    // Skip likely icons and small images
                    if (img.src && 
                        !img.src.includes('icon') && 
                        !img.src.includes('logo') && 
                        !img.src.includes('pixel') &&
                        !img.src.includes('1x1') &&
                        !img.src.includes('.svg') &&
                        (img.width > 200 || img.naturalWidth > 200)) {
                        console.log('Found content image:', img.src);
                        return normalizeImageURL(img.src);
                    }
                }
            }
        }
        
        // Priority 6: Any large image on the page
        var allImages = document.querySelectorAll('img');
        for (var i = 0; i < allImages.length; i++) {
            var img = allImages[i];
            if (img.src && 
                !img.src.includes('icon') && 
                !img.src.includes('logo') && 
                (img.width > 300 || img.naturalWidth > 300)) {
                console.log('Found large image:', img.src);
                return normalizeImageURL(img.src);
            }
        }
        
        console.log('No suitable image found');
        return null;
    }
    
    // Extract recipe structured data
    function extractRecipeData() {
        var recipeData = {};
        
        // Try to find JSON-LD recipe data
        var jsonLDScripts = document.querySelectorAll('script[type="application/ld+json"]');
        for (var i = 0; i < jsonLDScripts.length; i++) {
            try {
                var jsonData = JSON.parse(jsonLDScripts[i].textContent);
                if (jsonData['@type'] === 'Recipe' || 
                    (jsonData['@graph'] && jsonData['@graph'].some(function(item) { 
                        return item['@type'] === 'Recipe'; 
                    }))) {
                    console.log('Found Recipe JSON-LD data');
                    return jsonLDScripts[i].textContent;
                }
            } catch (e) {
                // Continue to next script
            }
        }
        
        return null;
    }
    
    // Main extraction logic
    var results = {
        url: window.location.href,
        title: document.title || getMetaContent('og:title') || '',
        description: getMetaContent('description') || getMetaContent('og:description') || '',
        imageURL: extractImage(),
        recipeData: extractRecipeData(),
        htmlContent: document.documentElement.innerHTML,
        text: document.body.innerText || document.body.textContent || ''
    };
    
    console.log('Extraction complete:', {
        url: results.url,
        title: results.title,
        imageURL: results.imageURL,
        hasRecipeData: !!results.recipeData,
        htmlLength: results.htmlContent.length,
        textLength: results.text.length
    });
    
    // Call the completion function with the results
    // This is the format expected by the Share Extension
    completionFunction(results);
    }
};

// Create an instance of the extension preprocessing JavaScript
var ExtensionPreprocessingJS = new ExtensionPreprocessingJS();