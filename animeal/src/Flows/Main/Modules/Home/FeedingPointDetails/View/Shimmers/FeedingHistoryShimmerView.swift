//
//  FeedingHistoryShimmerView.swift
//  animeal
//
//  Created by Mikhail Churbanov on 3/30/23.
//

import UIKit
import UIComponents
import Style

final class FeedingHistoryShimmerView: UIStackView {

    private enum Constants {
        static let feederShimmerCount = 3
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        axis = .vertical
        spacing = FeedingPointDetailsViewController.Constants.stackSpacing

        let titleShimmerView = ShimmerView(animationDirection: .leftRight)
        titleShimmerView.widthAnchor ~= 80
        titleShimmerView.heightAnchor ~= 24
        titleShimmerView.cornerRadius(12)
        addArrangedSubview(titleShimmerView)

        for _ in 0..<Constants.feederShimmerCount {
            addArrangedSubview(FeederShimmerView())
        }

        shimmerSubviews.forEach { $0.apply(style: .shimmer) }
    }

    func startAnimation(scheduler: ShimmerViewScheduler) {
        shimmerSubviews.forEach { $0.startAnimation(withScheduler: scheduler) }
        scheduler.start()
    }
}

private extension UIView {
    var shimmerSubviews: [ShimmerView] {
        let subviewsTree = subviews + subviews.flatMap { $0.shimmerSubviews }
        return subviewsTree.compactMap { $0 as? ShimmerView }
    }
}

private extension Style where Component == ShimmerView {
    static var shimmer: Style<ShimmerView> {
        .init { view in
            let design = view.designEngine
            view.backgroundColor = design.colors.backgroundPrimary
            view.border(
                color: design.colors.backgroundSecondary,
                width: .pixel
            )
            view.clipsToBounds = true
            view.shadow()
        }
    }
}
