//
//  PageIndicatorView.swift
//  UIComponents
//
//  Created by Диана Тынкован on 3.06.22.
//

import SwiftUI
import Style

extension PageIndicatorView {
    public class Model: ObservableObject {
        @Published public var availableWidth = CGFloat.zero
        @Published public var contentOffset = CGFloat.zero
        @Published public var numberOfPages = Int.zero

        public var activePageIndex: Int {
            guard availableWidth != CGFloat.zero else { return Int.zero }
            return Int(
                round(Double(contentOffset / availableWidth))
            )
        }
    }
}

public struct PageIndicatorView: View {
    // MARK: - Constants
    public enum Constants {
        public static let spacing: CGFloat = 4.0
        public static let maximumWidth: CGFloat = 13.0
        public static let minimumWidth: CGFloat = 5.0
        public static let normalHeight: CGFloat = 3.0
        public static let padding: CGFloat = 16.0
    }

    // MARK: - Private properties
    private var animationOffset: CGFloat {
        guard model.availableWidth != CGFloat.zero else { return CGFloat.zero }
        let progress = model.contentOffset / model.availableWidth
        return (minimumWidth + spacing) * progress
    }
    private let spacing: CGFloat
    private let maximumWidth: CGFloat
    private let minimumWidth: CGFloat
    private let normalHeight: CGFloat

    // MARK: - Engine
    @EnvironmentObject private var designEngine: StyleEngine

    // MARK: - Model
    @StateObject var model: Model

    // MARK: - Initialization
    public init(
        model: Model,
        spacing: CGFloat = Constants.spacing,
        maximumWidth: CGFloat = Constants.maximumWidth,
        minimumWidth: CGFloat = Constants.minimumWidth,
        normalHeight: CGFloat = Constants.normalHeight
    ) {
        self._model = StateObject(wrappedValue: model)
        self.spacing = spacing
        self.maximumWidth = maximumWidth
        self.minimumWidth = minimumWidth
        self.normalHeight = normalHeight
    }

    // MARK: - UI
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach((Int.zero..<model.numberOfPages), id: \.self) { index in
                let isActive = index == model.activePageIndex
                let width = isActive ? maximumWidth : minimumWidth
                let color = isActive ? designEngine.colors.destructive.color : designEngine.colors.disableTint.color
                Capsule()
                    .fill(color)
                    .frame(width: width, height: normalHeight)
            }
        }
        .overlay(
            Capsule()
                .fill(designEngine.colors.destructive.color)
                .frame(width: maximumWidth, height: normalHeight)
                .offset(x: animationOffset)
            ,alignment: .leading
        )
        .padding(.bottom, Constants.padding)
    }
}
