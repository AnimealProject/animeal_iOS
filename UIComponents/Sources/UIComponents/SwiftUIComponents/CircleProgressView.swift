//
//  CircleProgressView.swift
//  animeal
//
//  Created by Mikhail Churbanov on 2/6/23.
//

import SwiftUI
import Style

// MARK: - ProgressViewModel

public final class ProgressViewModel: ObservableObject {

    @Published public var progress: Double
    @Published public var isVisible: Bool

    public init(progress: Double, isVisible: Bool) {
        self.progress = progress
        self.isVisible = isVisible
    }

    public func updateProgress(_ progress: Double, duration: Double = 1.0) {
        withAnimation(.easeIn(duration: duration)) {
            self.progress = progress
        }
    }
}

// MARK: - CircleProgressView

public struct CircleProgressView: View {

    public var lineWidth: CGFloat = 4

    @ObservedObject var model: ProgressViewModel
    @EnvironmentObject var designEngine: StyleEngine

    @State var progress: Double = 0

    public init(model: ProgressViewModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(designEngine.colors.backgroundSecondary.color)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(model.progress, 0.5)))
                .stroke(style: strokeStyle)
                .foregroundColor(designEngine.colors.accent.color)
                .rotationEffect(Angle(degrees: 270.0))

            Circle()
                .trim(from: model.progress > 0.5 ? 0.25 : 0, to: CGFloat(min(model.progress, 1.0)))
                .stroke(style: strokeStyle)
                .foregroundColor(designEngine.colors.accent.color)
                .rotationEffect(Angle(degrees: 270.0))
        }
        .padding()
        .opacity(model.isVisible ? 1 : 0)
        .background(Color.clear)
        .scaledToFit()
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
    }
}

// MARK: - Preview

struct CircleProgressView_Previews: PreviewProvider {
    static let model = ProgressViewModel(progress: 0.7, isVisible: true)
    static let designEngine: StyleEngine = StyleDefaultEngine()

    static var previews: some View {
        CircleProgressView(model: model)
            .environmentObject(designEngine)
    }
}
