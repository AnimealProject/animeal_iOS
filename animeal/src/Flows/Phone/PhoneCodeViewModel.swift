// System
import Foundation

// SDK
import Common

final class PhoneCodesViewModel: PhoneCodesViewModelProtocol {
    // MARK: - Properties
    private lazy var allRegions = Region.allCases

    // MARK: - Dependencies
    private var selectedRegion: Region?
    private let handler: (Region) async -> Void
    private let completion: (() -> Void)?

    // MARK: - State
    var onHeaderHasBeenPrepared: ((PhoneCodesViewHeader) -> Void)?
    var onSnapshotHasBeenPrepared: ((DataSourceSnapshot) -> Void)?

    // MARK: - Initialization
    init(
        selectedRegion: Region?,
        handler: @escaping (Region) async -> Void,
        completion: (() -> Void)? = nil
    ) {
        self.selectedRegion = selectedRegion
        self.handler = handler
        self.completion = completion
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        updateHeader()
        updateSnapshot()
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: PhoneCodesViewActionEvent) {
        switch event {
        case .itemWasTapped(let identifier):
            guard let region = allRegions.first(where: { $0.rawValue == identifier }) else { return }
            Task { [weak self] in await self?.handler(region) }
            selectedRegion = region
            updateSnapshot()
            completion?()
        }
    }
}

private extension PhoneCodesViewModel {
    func updateHeader() {
        let viewHeader = PhoneCodesViewHeader(title: "Choose a country:")

        onHeaderHasBeenPrepared?(viewHeader)
    }

    func updateSnapshot() {
        let viewItems = allRegions.map { region in
            let item = PhoneCodesViewItem.common(
                identifier: region.rawValue,
                isSelected: region == selectedRegion,
                flag: region.flag,
                code: region.phoneNumberCode,
                countryName: region.countryName ?? .empty
            )
            return item
        }

        let viewSection = PhoneCodesViewSection.main

        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([viewSection])
        snapshot.appendItems(viewItems, toSection: viewSection)

        onSnapshotHasBeenPrepared?(snapshot)
    }
}
