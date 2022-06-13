import UIKit

public extension UIView {
    @discardableResult
    func prepareForAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

public struct ConstraintAttribute<T: AnyObject> {
    public let anchor: NSLayoutAnchor<T>
    public let const: CGFloat

    public init(anchor: NSLayoutAnchor<T>, const: CGFloat) {
        self.anchor = anchor
        self.const = const
    }
}

public struct LayoutGuideAttribute {
    public let guide: UILayoutSupport
    public let const: CGFloat

    public init(guide: UILayoutSupport, const: CGFloat) {
        self.guide = guide
        self.const = const
    }
}

public struct DimensionConstraintAttribute {
    public var anchor: NSLayoutDimension
    public var multiplier: CGFloat
    public var const: CGFloat

    public init(anchor: NSLayoutDimension, multiplier: CGFloat, const: CGFloat = 0.0) {
        self.anchor = anchor
        self.multiplier = multiplier
        self.const = const
    }
}

extension DimensionConstraintAttribute: Equatable {
    public static func == (lhs: DimensionConstraintAttribute, rhs: DimensionConstraintAttribute) -> Bool {
        lhs.anchor === rhs.anchor &&
        lhs.multiplier == rhs.multiplier &&
        lhs.const == rhs.const
    }
}

public func * (lhs: NSLayoutDimension, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs, multiplier: rhs)
}

public func * (lhs: CGFloat, rhs: NSLayoutDimension) -> DimensionConstraintAttribute {
    rhs * lhs
}

public func / (lhs: NSLayoutDimension, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs, multiplier: 1) / rhs
}

public func * (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs.anchor, multiplier: lhs.multiplier * rhs, const: lhs.const * rhs)
}

public func * (lhs: CGFloat, rhs: DimensionConstraintAttribute) -> DimensionConstraintAttribute {
    rhs * lhs
}

public func / (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs.anchor, multiplier: lhs.multiplier / rhs, const: lhs.const / rhs)
}

public func + (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs.anchor, multiplier: lhs.multiplier, const: lhs.const + rhs)
}

public func + (lhs: CGFloat, rhs: DimensionConstraintAttribute) -> DimensionConstraintAttribute {
    rhs + lhs
}

public func - (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> DimensionConstraintAttribute {
    DimensionConstraintAttribute(anchor: lhs.anchor, multiplier: lhs.multiplier, const: lhs.const - rhs)
}

public func - (lhs: CGFloat, rhs: DimensionConstraintAttribute) -> DimensionConstraintAttribute {
    lhs + rhs * -1
}

public func + <T>(lhs: NSLayoutAnchor<T>, rhs: CGFloat) -> ConstraintAttribute<T> {
    return ConstraintAttribute(anchor: lhs, const: rhs)
}

public func + (lhs: UILayoutSupport, rhs: CGFloat) -> LayoutGuideAttribute {
    return LayoutGuideAttribute(guide: lhs, const: rhs)
}

public func - <T>(lhs: NSLayoutAnchor<T>, rhs: CGFloat) -> ConstraintAttribute<T> {
    return ConstraintAttribute(anchor: lhs, const: -rhs)
}

public func - (lhs: UILayoutSupport, rhs: CGFloat) -> LayoutGuideAttribute {
    return LayoutGuideAttribute(guide: lhs, const: -rhs)
}

// ~= is used instead of == because Swift can't overload == for NSObject subclass
@discardableResult
public func ~= (lhs: NSLayoutYAxisAnchor, rhs: UILayoutSupport) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.bottomAnchor)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(greaterThanOrEqualTo: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= (lhs: NSLayoutDimension, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= (lhs: DimensionConstraintAttribute, rhs: NSLayoutDimension) -> NSLayoutConstraint {
    rhs ~= lhs
}

@discardableResult
public func ~= (lhs: DimensionConstraintAttribute, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    lhs.anchor ~= (rhs - lhs.const) / lhs.multiplier
}

@discardableResult
public func ~= (lhs: NSLayoutYAxisAnchor, rhs: LayoutGuideAttribute) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalTo: rhs.guide.bottomAnchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func ~= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    let constraint = lhs.constraint(equalToConstant: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= (lhs: NSLayoutDimension, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualTo: rhs.anchor, multiplier: rhs.multiplier, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= (lhs: DimensionConstraintAttribute, rhs: NSLayoutDimension) -> NSLayoutConstraint {
    let constraint = rhs.constraint(greaterThanOrEqualTo: lhs.anchor, multiplier: lhs.multiplier, constant: lhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= (lhs: DimensionConstraintAttribute, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    let factor = (rhs - lhs.const) / lhs.multiplier
    return lhs.multiplier > 0 ? lhs.anchor <= factor : factor <= lhs.anchor
}

@discardableResult
public func <= (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> NSLayoutConstraint {
    let value = (rhs - lhs.const) / lhs.multiplier
    return lhs.multiplier > 0 ? lhs.anchor <= value : value <= lhs.anchor
}

@discardableResult
public func <= (lhs: CGFloat, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    rhs * -1 <= -lhs
}

@discardableResult
public func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    let constraint = lhs.constraint(lessThanOrEqualToConstant: rhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func <= (lhs: CGFloat, rhs: NSLayoutDimension) -> NSLayoutConstraint {
    let constraint = rhs.constraint(greaterThanOrEqualToConstant: lhs)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= <T>(lhs: NSLayoutAnchor<T>, rhs: ConstraintAttribute<T>) -> NSLayoutConstraint {
    let constraint = lhs.constraint(greaterThanOrEqualTo: rhs.anchor, constant: rhs.const)
    constraint.isActive = true
    return constraint
}

@discardableResult
public func >= (lhs: NSLayoutDimension, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    rhs <= lhs
}

@discardableResult
public func >= (lhs: DimensionConstraintAttribute, rhs: NSLayoutDimension) -> NSLayoutConstraint {
    rhs <= lhs
}

@discardableResult
public func >= (lhs: DimensionConstraintAttribute, rhs: DimensionConstraintAttribute) -> NSLayoutConstraint {
    rhs <= lhs
}

@discardableResult
public func >= (lhs: DimensionConstraintAttribute, rhs: CGFloat) -> NSLayoutConstraint {
    rhs <= lhs
}

@discardableResult
public func >= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    rhs <= lhs
}
