// System
import Foundation

// SDK
import Services
import Common

protocol FetchFeedingPointsUseCaseLogic {
    func callAsFunction(force: Bool, oldSections: [SearchModelSection]) async throws -> [SearchModelSection]
}

final class FetchFeedingPointsUseCase: FetchFeedingPointsUseCaseLogic {
    private let feedingPointsService: FeedingPointsServiceProtocol

    init(
        feedingPointsService: FeedingPointsServiceProtocol = AppDelegate.shared.context.feedingPointsService
    ) {
        self.feedingPointsService = feedingPointsService
    }

    func callAsFunction(force: Bool, oldSections: [SearchModelSection]) async throws -> [SearchModelSection] {
        let result: [FullFeedingPoint] = try await { [weak self] in
            guard let self else { return [] }
            if force {
                return try await self.feedingPointsService.fetchAll()
            } else {
                return self.feedingPointsService.storedFeedingPoints
            }
        }()
        let sections = mapSections(result: result, oldSections: oldSections)
        let items = await mapItems(result: result)
        let filledSections = sections.map { section in
            var updatedSection = section
            updatedSection.items = items[section.title] ?? []
            return updatedSection
        }
        return filledSections
    }

    private func mapSections(result: [FullFeedingPoint], oldSections: [SearchModelSection]) -> [SearchModelSection] {
        let identifiableOldSections: [String: SearchModelSection] = oldSections
            .reduce([String: SearchModelSection]()) { partialResult, oldSection in
                var result = partialResult
                result[oldSection.identifier] = oldSection
                return result
            }
        return result
            .map { $0.feedingPoint.localizedCity.removeHtmlTags() }
            .uniqueValues
            .map {
                let identifier = $0
                let expanded = identifiableOldSections[identifier]?.expanded == true
                return SearchModelSection(
                    identifier: identifier,
                    title: $0,
                    items: [],
                    expanded: expanded
                )
            }
    }

    private func mapItems(result: [FullFeedingPoint]) async -> [String: [SearchModelItem]] {
        await result.asyncReduce([String: [SearchModelItem]]()) { partialResult, fullPoint in
            var result: [String: [SearchModelItem]] = partialResult
            let point = fullPoint.feedingPoint
            let item = SearchModelItem(
                identifier: point.id,
                name: point.localizedName.removeHtmlTags(),
                description: point.localizedDescription.removeHtmlTags(),
                icon: fullPoint.imageURL,
                status: .init(point.status),
                category: .init(point.category?.tag ?? .dogs),
                isFavorite: fullPoint.isFavorite
            )
            let city = point.localizedCity.removeHtmlTags()
            var items = result[city] ?? []
            items.append(item)
            result.updateValue(items, forKey: city)

            return result
        }
    }
}
