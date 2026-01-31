import SwiftUI

// MARK: - TastoryTextField Component
struct TastoryTextField: View {
    @Binding var text: String
    let placeholder: String
    var leadingIcon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: TastorySpacing.sm) {
            // Leading Icon
            if let icon = leadingIcon {
                Image(systemName: icon)
                    .font(.system(size: TastoryIconSize.medium))
                    .foregroundColor(TastoryColors.secondaryText)
            }

            // Text Field
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.primaryText)
                    .focused($isFocused)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
            } else {
                TextField(placeholder, text: $text)
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.primaryText)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .focused($isFocused)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }
            }

            // Clear button when focused and has text
            if isFocused && !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: TastoryIconSize.medium))
                        .foregroundColor(TastoryColors.tertiaryText)
                }
            }
        }
        .padding(.horizontal, TastorySpacing.md)
        .frame(height: 48)
        .background(Color(hex: "F3F4F6"))
        .cornerRadius(TastoryRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: TastoryRadius.medium)
                .stroke(isFocused ? TastoryColors.primaryGreen : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - TastorySearchField (Specialized for search)
struct TastorySearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        TastoryTextField(
            text: $text,
            placeholder: placeholder,
            leadingIcon: "magnifyingglass",
            keyboardType: .default,
            autocapitalization: .never,
            submitLabel: .search,
            onSubmit: onSubmit
        )
    }
}

// MARK: - TastoryLargeTextField (For titles)
struct TastoryLargeTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(TastoryColors.primaryText)
    }
}

// MARK: - Preview
#Preview("Text Fields") {
    VStack(spacing: 20) {
        TastoryTextField(
            text: .constant(""),
            placeholder: "Enter recipe URL",
            leadingIcon: "link"
        )

        TastoryTextField(
            text: .constant("https://example.com/recipe"),
            placeholder: "Enter recipe URL",
            leadingIcon: "link"
        )

        TastorySearchField(
            text: .constant(""),
            placeholder: "Search recipes, ingredients..."
        )

        TastorySearchField(
            text: .constant("pasta"),
            placeholder: "Search recipes, ingredients..."
        )

        TastoryTextField(
            text: .constant(""),
            placeholder: "Password",
            isSecure: true
        )

        TastoryLargeTextField(
            text: .constant(""),
            placeholder: "Recipe Title"
        )
        .padding(.horizontal)

        TastoryLargeTextField(
            text: .constant("Homemade Pasta"),
            placeholder: "Recipe Title"
        )
        .padding(.horizontal)
    }
    .padding()
    .background(TastoryColors.background)
}
