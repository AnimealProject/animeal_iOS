import UIKit


// TODO:  Add Model

class CircleView: UIView {
    private let colorLayer = CALayer()
    private let shadow = UIView()
    private var shape = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        layer.cornerRadius = 32

        shadow.frame = frame
        shadow.clipsToBounds = false
        addSubview(shadow)

        shape.frame = frame
        shape.layer.cornerRadius = 32
        shape.clipsToBounds = true
        addSubview(shape)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addShadow(_ color: UIColor) {
        shadow.layer.sublayers?.forEach { layer in
            layer.removeFromSuperlayer()
        }

        let shadowBezierPath = UIBezierPath(roundedRect: shadow.bounds, cornerRadius: 0)
        let shadowLayer = CALayer()
        shadowLayer.shadowPath = shadowBezierPath.cgPath
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = 0.15
        shadowLayer.shadowRadius = 8
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.bounds = shadow.bounds
        shadowLayer.position = shadow.center
        shadow.layer.addSublayer(shadowLayer)
    }

    func fill(_ color: UIColor) {
        colorLayer.removeFromSuperlayer()
        colorLayer.backgroundColor = color.cgColor
        colorLayer.bounds = shape.bounds
        colorLayer.position = shape.center
        shape.layer.addSublayer(colorLayer)
    }
}
