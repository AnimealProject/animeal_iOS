import UIKit
import Style

public final class StatusView: UILabel {
    // MARK: Private properties
    private let label = UILabel()
    private let statusImageView = UIImageView()
    private let mapper: StatusMapperProtocol

    // MARK: - Initialization

    init(mapper: StatusMapperProtocol = StatusMapper()) {
        self.mapper = mapper
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: StatusModel) {
        label.text = model.title
        statusImageView.image = mapper.map(model.status)
        label.textColor = mapper.map(model.status)
    }

    private func setup() {
        addSubview(label.prepareForAutoLayout())
        addSubview(statusImageView.prepareForAutoLayout())

        statusImageView.leadingAnchor ~= leadingAnchor
        statusImageView.topAnchor ~= topAnchor
        statusImageView.bottomAnchor ~= bottomAnchor

        label.leadingAnchor ~= statusImageView.trailingAnchor + 4
        label.lastBaselineAnchor ~= lastBaselineAnchor
        label.font = designEngine.fonts.primary.regular(12).uiFont
    }
}

// MARK: - Status model
public struct StatusModel {
    public let status: Status

    public init(
        status: Status
    ) {
        self.status = status
    }

    public var title: String {
        switch status {
        case .success(let text),
                .attention(let text),
                .error(let text):
            return text
        }
    }
}

public enum Status {
    case success(String)
    case attention(String)
    case error(String)
}

// MARK: - SatatusImageProviderProtocol
public protocol StatusMapperProtocol {
    func map(_ status: Status) -> UIImage
    func map(_ status: Status) -> UIColor
}

public struct StatusMapper: StatusMapperProtocol {
    public init() {}

    public func map(_ status: Status) -> UIImage {
        switch status {
        case .success:
            return Asset.Images.successStatus.image
        case .attention:
            return Asset.Images.attentionStatus.image
        case .error:
            return Asset.Images.errorStatus.image
        }
    }

    public func map(_ status: Status) -> UIColor {
        switch status {
        case .success:
            return Asset.Colors.darkMint.color
        case .attention:
            return Asset.Colors.orangePeel.color
        case .error:
            return Asset.Colors.watermelon.color
        }
    }
}
