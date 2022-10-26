import UIKit

public enum ShimmerComponents {
    public enum Direction {
        case leftRight
        case rightLeft
        case topBottom
        case bottomTop
        case topLeftBottomRight
        case bottomRightTopLeft
        case custom(startPoint: CGPoint, endPoint: CGPoint)

        var startPoint: CGPoint {
            switch self {
            case .leftRight:
                return CGPoint(x: 0.0, y: 0.5)
            case .rightLeft:
                return CGPoint(x: 1.0, y: 0.5)
            case .topBottom:
                return CGPoint(x: 0.5, y: 0.0)
            case .bottomTop:
                return CGPoint(x: 0.5, y: 1.0)
            case .topLeftBottomRight:
                return CGPoint(x: 0.0, y: 0.0)
            case .bottomRightTopLeft:
                return CGPoint(x: 1.0, y: 1.0)
            case let .custom(startPoint, _):
                return startPoint
            }
        }

        var endPoint: CGPoint {
            switch self {
            case .leftRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .rightLeft:
                return CGPoint(x: 0.0, y: 0.5)
            case .topBottom:
                return CGPoint(x: 0.5, y: 1.0)
            case .bottomTop:
                return CGPoint(x: 0.5, y: 0.0)
            case .topLeftBottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            case .bottomRightTopLeft:
                return CGPoint(x: 0.0, y: 0.0)
            case let .custom(_, endPoint):
                return endPoint
            }
        }
    }

    public enum Transition {
        case crossDisolve(duration: TimeInterval)
    }

    public enum Animation { }
}

extension ShimmerComponents.Animation {
    public enum RelativeUniformDistribution {
        public static func values(basedOn rect: CGRect) -> [[CGFloat]] {
            let ratio = (rect.width / 2) / rect.width
            let preValues: [CGFloat] = [-2.0, -2.0 + ratio, -2.0 + 2 * ratio]
            let startValues: [CGFloat] = [-ratio, 0.0, ratio]
            let postValues: [CGFloat] = [2 * ratio, 2.0 - ratio, 2.0]
            return [preValues, startValues, postValues]
        }

        public static func keyTimes(
            basedOn rect: CGRect,
            globalCoordinatesConverter: ((CGRect) -> CGRect)?
        ) -> [NSNumber] {
            guard let globalCoordinatesConverter = globalCoordinatesConverter else {
                return [0.0, 0.5, 1.0]
            }

            let appSizeData = UIScreen.main.bounds

            let globalX = globalCoordinatesConverter(rect).origin.x
            let containerWith = appSizeData.width

            let startPoint = globalX
            let endPoint = startPoint + rect.width

            let relativeStartPoint = startPoint / containerWith
            let relativeEndPoint = endPoint / containerWith

            let relativeMiddlePoint = (relativeStartPoint + relativeEndPoint) / 2.0

            return [0.0, relativeMiddlePoint as NSNumber, 1.0]
        }
    }

    public enum Default {
        public static func values(basedOn rect: CGRect) -> [[CGFloat]] {
            [[-1.0, -0.5, 0.0], [1.0, 1.5, 2.0]]
        }

        public static func keyTimes(
            basedOn rect: CGRect,
            globalCoordinatesConverter: ((CGRect) -> CGRect)?
        ) -> [NSNumber] {
            [0.0, 0.5, 1.0]
        }
    }
}
