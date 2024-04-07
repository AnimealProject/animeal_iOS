import Foundation

protocol SearchFeedingPointsUseCaseLogic {
    func callAsFunction(
        _ sections: [SearchModelSection],
        searchString: String?
    ) -> [SearchModelSection]
}

final class SearchFeedingPointsUseCase: SearchFeedingPointsUseCaseLogic {
    func callAsFunction(
        _ sections: [SearchModelSection],
        searchString: String?
    ) -> [SearchModelSection] {
        guard let searchString, !searchString.isEmpty
        else { return sections }

        let filteredSections: [SearchModelSection] = sections.compactMap { section in
            let items = section.items.filter { $0.name.localizedCaseInsensitiveContains(searchString) }
            guard !items.isEmpty else { return nil }

            return SearchModelSection(
                identifier: section.identifier,
                title: section.title,
                items: items,
                expanded: true
            )
        }

        return filteredSections
    }
}
