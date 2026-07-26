import SwiftUI

struct SwipeableFeedingCardView: View {
    private enum Constants {
        static let buttonSize: CGFloat = 77
        static let gap: CGFloat = 16
        static let revealWidth = buttonSize * 2 + gap * 2
    }

    let item: FeedingListItem
    let isSwipeEnabled: Bool
    @Binding var openedItemID: String?
    let onApprove: () -> Void
    let onReject: () -> Void

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var cardHeight: CGFloat?

    private var isOpen: Bool {
        openedItemID == item.id
    }

    private var currentOffset: CGFloat {
        let committedOffset: CGFloat = isOpen ? -Constants.revealWidth : 0
        return max(-Constants.revealWidth, min(0, committedOffset + dragTranslation))
    }

    var body: some View {
        if isSwipeEnabled {
            ZStack(alignment: .trailing) {
                HStack(spacing: Constants.gap) {
                    FeedingQuickActionButton(status: .approved, width: Constants.buttonSize, action: approve)
                    FeedingQuickActionButton(status: .rejected, width: Constants.buttonSize, action: reject)
                }
                .padding(.leading, Constants.gap)
                .frame(height: cardHeight)

                FeedingCardView(item: item)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { cardHeight = proxy.size.height }
                                .onChange(of: proxy.size.height) { _, newHeight in
                                    cardHeight = newHeight
                                }
                        }
                    )
                    .offset(x: currentOffset)
                    .gesture(dragGesture)
                    .onTapGesture { close() }
            }
        } else {
            FeedingCardView(item: item)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .updating($dragTranslation) { value, state, _ in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let committedOffset: CGFloat = isOpen ? -Constants.revealWidth : 0
                let projectedOffset = committedOffset + value.translation.width
                let shouldReveal = projectedOffset < -Constants.revealWidth / 2
                setOpen(shouldReveal)
            }
    }

    private func approve() {
        onApprove()
        close()
    }

    private func reject() {
        onReject()
        close()
    }

    private func close() {
        setOpen(false)
    }

    private func setOpen(_ open: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            openedItemID = open ? item.id : nil
        }
    }
}
