import SwiftUI

struct SwipeableFeedingCardView: View {
    private enum Constants {
        static let buttonSize: CGFloat = 77
        static let gap: CGFloat = 16
        static let revealWidth = buttonSize * 2 + gap * 2

        // Eased-drag curve: below `easeThreshold`, the offset tracks the finger at
        // `preThresholdSlope`; above it, it accelerates to reach 1.0 exactly at progress 1.0.
        static let easeThreshold: CGFloat = 0.4
        static let preThresholdSlope: CGFloat = 0.5
    }

    let item: FeedingListItem
    let isSwipeEnabled: Bool
    @Binding var openedItemID: String?
    let onApprove: () -> Void
    let onReject: () -> Void

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var cardHeight: CGFloat?

    var body: some View {
        if isSwipeEnabled {
            ZStack(alignment: .trailing) {
                HStack(spacing: Constants.gap) {
                    FeedingQuickActionButton(status: .approve, width: Constants.buttonSize, action: approve)
                    FeedingQuickActionButton(status: .reject, width: Constants.buttonSize, action: reject)
                }
                .padding(.leading, Constants.gap)
                .frame(height: cardHeight)
                .scaleEffect(revealProgress, anchor: .trailing)
                .opacity(revealProgress)

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
}

// MARK: - Swipe-to-reveal drag

//                 ┌───────────────┐
//                 │  finger down  │
//                 └───────┬───────┘
//                         ▼
//         ┌──────────────────────────────-─┐
//         │ live drag update               │◀─-┐
//         │ dragTranslation → currentOffset│   │ finger still moving
//         └───────────────┬────────────────┘   │
//                         └────────────────────┘
//                         ▼ finger lifted
//                 ┌───────────────────────┐
//                 │ dragged > 50% of      │
//                 │ revealWidth?          │
//                 └─────┬─────────┬───────┘
//                   yes │         │ no
//                       ▼         ▼
//               ┌───────────┐ ┌───────────┐
//               │   OPEN    │ │  CLOSED   │
//               │ offset =  │ │ offset =  │
//               │-revealWidth││    0     │
//               └───────────┘ └───────────┘
//                       │             │
//             (tap card / Approve / Reject)
//                       └──────┬──────┘
//                              ▼
//                         close → CLOSED
private extension SwipeableFeedingCardView {
    var isOpen: Bool {
        openedItemID == item.id
    }

    // Recomputed on every frame of the live drag.
    var currentOffset: CGFloat {
        let committedOffset: CGFloat = isOpen ? -Constants.revealWidth : 0
        let rawOffset = max(-Constants.revealWidth, min(0, committedOffset + dragTranslation))
        let progress = -rawOffset / Constants.revealWidth
        return -easedProgress(progress) * Constants.revealWidth
    }

    // How visually "revealed" the action buttons are, 0...1, tracking currentOffset live.
    var revealProgress: CGFloat {
        -currentOffset / Constants.revealWidth
    }

    // Remaps a 0...1 drag progress to a differently-shaped 0...1 progress: below
    // `easeThreshold` the card lags behind the finger, past it the card accelerates to
    // catch up (landing exactly on 1.0 at progress 1.0) — reads as a magnetic snap once
    // you've dragged far enough.
    func easedProgress(_ progress: CGFloat) -> CGFloat {
        guard progress > Constants.easeThreshold else {
            return progress * Constants.preThresholdSlope
        }
        let outputAtThreshold = Constants.easeThreshold * Constants.preThresholdSlope
        let acceleratedRange = (progress - Constants.easeThreshold) / (1 - Constants.easeThreshold)
        let remainingOutput = 1 - outputAtThreshold
        return min(1, outputAtThreshold + acceleratedRange * remainingOutput)
    }

    var dragGesture: some Gesture {
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

    func approve() {
        onApprove()
        close()
    }

    func reject() {
        onReject()
        close()
    }

    func close() {
        setOpen(false)
    }

    func setOpen(_ open: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            openedItemID = open ? item.id : nil
        }
    }
}
