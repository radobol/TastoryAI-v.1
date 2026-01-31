import SwiftUI

// MARK: - TastoryLoadingView Component
struct TastoryLoadingView: View {
    let title: String
    var message: String? = nil
    var icon: String = "fork.knife"
    var showProgress: Bool = false
    var progress: Double = 0

    @State private var isPulsing = false
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: TastorySpacing.lg) {
            // Pulsing Icon Container
            ZStack {
                Circle()
                    .fill(TastoryColors.lightGreenBg)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Image(systemName: icon)
                    .font(.system(size: TastoryIconSize.xLarge))
                    .foregroundColor(TastoryColors.primaryGreen)
            }

            // Title
            Text(title)
                .font(TastoryTypography.title)
                .foregroundColor(TastoryColors.primaryText)
                .multilineTextAlignment(.center)

            // Message with animated dots
            if let message = message {
                Text(message + String(repeating: ".", count: dotCount))
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .onReceive(timer) { _ in
                        dotCount = (dotCount + 1) % 4
                    }
            }

            // Progress Bar
            if showProgress {
                VStack(spacing: TastorySpacing.xs) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(TastoryColors.border)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(TastoryColors.primaryGreen)
                                .frame(width: geometry.size.width * progress, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, TastorySpacing.xxl)

                    Text("\(Int(progress * 100))%")
                        .font(TastoryTypography.caption)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(TastorySpacing.xl)
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Compact Loading Indicator
struct TastoryLoadingIndicator: View {
    var size: CGFloat = 60
    var iconSize: CGFloat = 24
    var icon: String = "fork.knife"

    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(TastoryColors.lightGreenBg)
                .frame(width: size, height: size)
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(TastoryColors.primaryGreen)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Preview
#Preview("Full Loading View") {
    TastoryLoadingView(
        title: "Importing Recipe",
        message: "Analyzing content"
    )
    .background(TastoryColors.background)
}

#Preview("Loading with Progress") {
    TastoryLoadingView(
        title: "Extracting Recipe",
        message: "Processing image",
        icon: "doc.text.magnifyingglass",
        showProgress: true,
        progress: 0.65
    )
    .background(TastoryColors.background)
}

#Preview("Compact Loading") {
    VStack(spacing: 20) {
        TastoryLoadingIndicator()

        TastoryLoadingIndicator(size: 40, iconSize: 16)

        TastoryLoadingIndicator(icon: "photo")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(TastoryColors.background)
}
