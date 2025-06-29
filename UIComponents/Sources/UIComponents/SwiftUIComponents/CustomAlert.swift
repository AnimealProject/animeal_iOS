import SwiftUI
import Style

// MARK: - CustomAlert View

public struct CustomAlertView: View {

    @EnvironmentObject var designEngine: StyleEngine

    private let viewModel: ViewModel
    private let isPresented: Bool

    public init(
        viewModel: ViewModel,
        isPresented: Bool = true
    ) {
        self.viewModel = viewModel
        self.isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            if isPresented {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // do nothing
                    }

                alertContainer.transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }

    private var alertContainer: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                if let title = viewModel.title {
                    Text(title)
                        .font(designEngine.fonts.primary.bold(18)?.font ?? .system(size: 18, weight: .bold))
                        .foregroundColor(designEngine.colors.textPrimary.color)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }

                if let message = viewModel.message {
                    Text(message)
                        .font(designEngine.fonts.primary.medium(14)?.font ?? .system(size: 14, weight: .medium))
                        .foregroundColor(designEngine.colors.textSecondary.color)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button(action: { viewModel.action(.primary) }) {
                    HStack {
                        Spacer()
                        Text(viewModel.primaryButtonTitle)
                            .font(designEngine.fonts.primary.bold(16)?.font ?? .system(size: 16))
                            .foregroundColor(designEngine.colors.alwaysLight.color)
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(designEngine.colors.accent.color)
                    .cornerRadius(25)
                }

                if let secondaryButtonTitle = viewModel.secondaryButtonTitle {
                    Button(action: { viewModel.action(.secondary) }) {
                        HStack {
                            Spacer()
                            Text(secondaryButtonTitle)
                                .font(designEngine.fonts.primary.medium(16)?.font ?? .system(size: 16))
                                .foregroundColor(designEngine.colors.textSecondary.color)
                            Spacer()
                        }
                        .frame(height: 50)
                        .background(designEngine.colors.alwaysLight.color)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(designEngine.colors.disabled.color, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(designEngine.colors.backgroundPrimary.color)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - CustomAlert Modifier

public struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let viewModel: CustomAlertView.ViewModel

    public func body(content: Content) -> some View {
        content
            .overlay(
                CustomAlertView(viewModel: viewModel, isPresented: isPresented)
            )
    }
}

public extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        viewModel: CustomAlertView.ViewModel
    ) -> some View {
        self.modifier(CustomAlertModifier(isPresented: isPresented, viewModel: viewModel))
    }
}

// MARK: - CustomAlertModel
extension CustomAlertView {
    public struct ViewModel {
        public let title: String?
        public let message: String?
        public let primaryButtonTitle: String
        public let secondaryButtonTitle: String?
        public let action: (Action) -> Void

        public init(
            title: String?,
            message: String?,
            primaryButtonTitle: String,
            secondaryButtonTitle: String?,
            action: @escaping (Action) -> Void
        ) {
            self.title = title
            self.message = message
            self.primaryButtonTitle = primaryButtonTitle
            self.secondaryButtonTitle = secondaryButtonTitle
            self.action = action
        }

        public enum Action {
            case primary
            case secondary
        }
    }
}

// MARK: - Preview
struct CustomAlert_Previews: PreviewProvider {
    static let designEngine: StyleEngine = StyleDefaultEngine()

    static var previews: some View {
        VStack {
            Text("Background Content")
                .font(.title)
                .padding()

            Text("This content should be dimmed when alert is shown")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .customAlert(
            isPresented: .constant(true),
            viewModel: CustomAlertView.ViewModel(
                title: "Confirm Action",
                message: "Are you sure you want to perform this action? This cannot be undone.",
                primaryButtonTitle: "Primary",
                secondaryButtonTitle: "Secondary",
                action: { action in
                    switch action {
                    case .primary:
                        print("Primary")
                    case .secondary:
                        print("Secondary")
                    }
                }
            )
        )
        .environmentObject(designEngine)
    }
}
