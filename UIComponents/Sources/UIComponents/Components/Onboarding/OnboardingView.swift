//
//  OnboardingView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import UIKit

extension OnboardingView {
    public struct Model {
        public let steps: [Step]

        public init(steps: [Step]) {
            self.steps = steps
        }
    }

    public struct Step {
        public let identifier: String
        public let image: UIImage?
        public let title: String
        public let text: String

        public init(
            identifier: String,
            image: UIImage?,
            title: String,
            text: String
        ) {
            self.identifier = identifier
            self.image = image
            self.title = title
            self.text = text
        }
    }
}

public final class OnboardingView: UIView {
    // MARK: - UI properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let item = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        item.translatesAutoresizingMaskIntoConstraints = false
        item.showsHorizontalScrollIndicator = false
        item.isPagingEnabled = true
        return item
    }()

    private let stepperView: OnboardingStepperView = {
        let item = OnboardingStepperView()
        item.translatesAutoresizingMaskIntoConstraints = false
        return item
    }()

    // MARK: - Private properties
    private var items: [Step] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Initialization
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        items = model.steps
        stepperView.configure(
            OnboardingStepperView.Model(
                numberOfSteps: model.steps.count
            )
        )
    }

    // MARK: - Setup
    private func setup() {
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        addSubview(stepperView)
        stepperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stepperView.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        stepperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stepperView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        collectionView.register(
            OnboardingImageStepCell.self,
            forCellWithReuseIdentifier: OnboardingImageStepCell.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension OnboardingView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stepperView.configureAvailableWidth(scrollView.bounds.width)
        stepperView.configureContentOffset(scrollView.contentOffset.x)
    }
}

extension OnboardingView: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width
        let availableHeight = collectionView.bounds.height
        return CGSize(width: availableWidth, height: availableHeight)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return CGFloat.zero
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return CGFloat.zero
    }
}

extension OnboardingView: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingImageStepCell.reuseIdentifier,
            for: indexPath
        ) as? OnboardingImageStepCell
        else { return UICollectionViewCell() }
        let item = items[indexPath.item]
        cell.configure(item)
        return cell
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }
}
