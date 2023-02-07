// System
import Foundation

// SDK
import UIComponents
import Style

final class SearchViewModel: SearchViewModelProtocol {
    // MARK: - Private properties
    private lazy var shimmerScheduler = ShimmerViewScheduler()

    // MARK: - Dependencies
    private let model: SearchModelProtocol
    private let coordinator: SearchCoordinatable
    private let sectionMapper: SearchViewSectionMappable

    // MARK: - State
    var onErrorIsNeededToDisplay: ((String) -> Void)?
    var onContentStateWasPrepared: ((SearchViewContentState) -> Void)?
    var onFiltersWerePrepared: ((SearchViewFilters) -> Void)?
    var onSearchInputWasPrepared: ((SearchViewInput) -> Void)?

    // MARK: - Initialization
    init(
        model: SearchModelProtocol,
        coordinator: SearchCoordinatable,
        sectionMapper: SearchViewSectionMappable
    ) {
        self.model = model
        self.coordinator = coordinator
        self.sectionMapper = sectionMapper
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        updateViewFilters()
        updateViewInput()

        shimmerScheduler.start()
        updateViewItems { [weak self] in
            self?.updateViewLoadingItems() ?? []
        }
        updateViewItems { [weak self] in
            guard let self else { return [] }
            self.shimmerScheduler.stop()
            return try await self.updateViewContentItems(force: true)
        }
    }

    // MARK: - Interaction
    func handleTextEvent(_ event: SearchViewTextEvent) {
        switch event {
        case .didChange(let text):
            updateViewItems { [weak self] in
                await self?.updateViewSearchContentItems(text) ?? []
            }
        }
    }

    func handleActionEvent(_ event: SearchViewActionEvent) {
        switch event {
        case .sectionDidTap(let identifier):
            model.toogleFeedingPoint(forIdentifier: identifier)
            updateViewItems { [weak self] in
                try await self?.updateViewContentItems(force: false) ?? []
            }
        case .itemDidTap(let identifier):
            coordinator.move(to: .details(identifier: identifier))
        case .filterDidTap(let identifier):
            updateViewItems { [weak self] in
                let viewItems = await self?.updateViewFilterContentItems(
                    identifier
                ) ?? []
                self?.updateViewInput()
                return viewItems
            }
        }
    }
}

private extension SearchViewModel {
    private func updateViewFilters() {
        Task { [weak self] in
            guard let self else { return }
            let modelFilters = await self.model.fetchFeedingPointsFilters()
            let viewFilters = SearchViewFilters(
                selectedItemIdentifier:
                    modelFilters.first { $0.isSelected }?.identifier ??
                        modelFilters.first?.identifier,
                items: modelFilters.map {
                    SearchViewFilter(identifier: $0.identifier, title: $0.title)
                }
            )
            self.onFiltersWerePrepared?(viewFilters)
        }
    }

    private func updateViewInput() {
        let viewSearchInput = SearchViewInput(
            identifier: UUID().uuidString,
            state: .normal,
            content: SearchTextContentView.Model(
                icon: Asset.Images.search.image,
                placeholder: L10n.Search.SearchBar.placeholder,
                text: model.fetchFilteringText(),
                isEditable: true
            )
        )
        onSearchInputWasPrepared?(viewSearchInput)
    }

    private func updateViewItems(
        _ operation: @escaping () async throws -> [SearchViewSectionWrapper]
    ) {
        Task { [weak self] in
            do {
                let viewSections = try await operation()

                guard !viewSections.isEmpty else {
                    let viewEmpty = SearchViewEmpty(
                        text: L10n.Search.Empty.text
                    )
                    self?.onContentStateWasPrepared?(.empty(viewEmpty))
                    return
                }

                var snapshot = SearchViewSnapshot()
                snapshot.appendSections(viewSections)
                viewSections.forEach { viewSection in
                    snapshot.appendItems(viewSection.items, toSection: viewSection)
                }

                self?.onContentStateWasPrepared?(.snapshot(snapshot))
            } catch {
                self?.coordinator.displayAlert(message: error.localizedDescription)
            }
        }
    }

    private func updateViewContentItems(force: Bool) async throws -> [SearchViewSectionWrapper] {
        let modelSections = try await model.fetchFeedingPoints(force: force)
        let viewSections = sectionMapper.mapSections(modelSections)
        return viewSections
    }

    private func updateViewSearchContentItems(
        _ searchString: String?
    ) async -> [SearchViewSectionWrapper] {
        let modelSections = await model.filterFeedingPoints(withSearchString: searchString)
        let viewSections = sectionMapper.mapSections(modelSections)
        return viewSections
    }

    private func updateViewFilterContentItems(
        _ identifier: String
    ) async -> [SearchViewSectionWrapper] {
        let modelSections = await model.filterFeedingPoints(withFilter: identifier)
        let viewSections = sectionMapper.mapSections(modelSections)
        return viewSections
    }

    private func updateViewLoadingItems() -> [SearchViewSectionWrapper] {
        let viewSections = (0...1).map { _ in
            SearchViewSection(
                identifier: UUID().uuidString,
                items: (0...1).map { _ in
                    SearchPointShimmerViewItem(
                        identifier: UUID().uuidString,
                        scheduler: shimmerScheduler
                    )
                },
                header: SearchViewSupplementaryShimmerItem(scheduler: shimmerScheduler)
            )
        }
        return viewSections.map(SearchViewSectionWrapper.init)
    }
}
