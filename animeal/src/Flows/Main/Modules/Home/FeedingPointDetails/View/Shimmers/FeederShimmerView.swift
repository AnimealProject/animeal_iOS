//
//  FeederShimmerView.swift
//  animeal
//
//  Created by Mikhail Churbanov on 3/30/23.
//

import UIKit
import UIComponents
import Style

final class FeederShimmerView: UIView {

    private enum Constants {
        static let shimmerShortLabelWidth: CGFloat = 90
        static let shimmerLongLabelWidth: CGFloat = 120
        static let shimmerLabelDeltaWidth: CGFloat = 20
        static let shimmerLabelHeight: CGFloat = 20
        static let shimmerCircleImageRadius: CGFloat = 28
        static let shimmerLabelCornerRadius: CGFloat = 12
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    func setup() {
        let imageShimmerView = ShimmerView(animationDirection: .leftRight)
        addSubview(imageShimmerView.prepareForAutoLayout())
        imageShimmerView.leadingAnchor ~= leadingAnchor
        imageShimmerView.topAnchor ~= topAnchor
        imageShimmerView.bottomAnchor ~= bottomAnchor
        imageShimmerView.heightAnchor ~= Constants.shimmerCircleImageRadius * 2
        imageShimmerView.widthAnchor ~= Constants.shimmerCircleImageRadius * 2
        imageShimmerView.cornerRadius(Constants.shimmerCircleImageRadius)

        let titleShimmerView = ShimmerView(animationDirection: .leftRight)
        addSubview(titleShimmerView.prepareForAutoLayout())
        titleShimmerView.topAnchor ~= topAnchor + 4
        titleShimmerView.leadingAnchor ~= imageShimmerView.trailingAnchor + 16
        titleShimmerView.widthAnchor ~= randomShimmerShortLabelWidth
        titleShimmerView.heightAnchor ~= Constants.shimmerLabelHeight
        titleShimmerView.cornerRadius(Constants.shimmerLabelCornerRadius)

        let subtitleShimmerView = ShimmerView(animationDirection: .leftRight)
        addSubview(subtitleShimmerView.prepareForAutoLayout())
        subtitleShimmerView.topAnchor ~= titleShimmerView.bottomAnchor + 8
        subtitleShimmerView.leadingAnchor ~= titleShimmerView.leadingAnchor
        subtitleShimmerView.widthAnchor ~= randomShimmerLongLabelWidth
        subtitleShimmerView.heightAnchor ~= Constants.shimmerLabelHeight
        subtitleShimmerView.cornerRadius(Constants.shimmerLabelCornerRadius)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var randomShimmerShortLabelWidth: CGFloat {
        let minWidth = Constants.shimmerShortLabelWidth
        let maxWidth = Constants.shimmerShortLabelWidth + Constants.shimmerLabelDeltaWidth
        return CGFloat.random(in: minWidth...maxWidth)
    }

    private var randomShimmerLongLabelWidth: CGFloat {
        let minWidth = Constants.shimmerLongLabelWidth
        let maxWidth = Constants.shimmerLongLabelWidth + Constants.shimmerLabelDeltaWidth
        return CGFloat.random(in: minWidth...maxWidth)
    }
}
