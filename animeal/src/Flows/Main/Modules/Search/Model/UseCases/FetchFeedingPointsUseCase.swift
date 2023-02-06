// System
import Foundation

// SDK
import Services
import Common

protocol FetchFeedingPointsUseCaseLogic {
    func callAsFunction() async throws -> [SearchModelSection]
}

final class FetchFeedingPointsUseCase: FetchFeedingPointsUseCaseLogic {
    private let networkService: NetworkServiceProtocol
    private let dataService: DataStoreServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        dataService: DataStoreServiceProtocol = AppDelegate.shared.context.dataStoreService
    ) {
        self.networkService = networkService
        self.dataService = dataService
    }
    
    func callAsFunction() async throws -> [SearchModelSection] {
        let result = try await networkService.query(
            request: .list(animeal.FeedingPoint.self)
        )
        let sections = mapSections(result: result)
        let items = await mapItems(result: result)
        let filledSections = sections.map { section in
            var updatedSection = section
            updatedSection.items = items[section.title] ?? []
            return updatedSection
        }
        return filledSections
    }
    
    private func mapSections(result: [FeedingPoint]) -> [SearchModelSection] {
        result
            .map { $0.localizedCity.removeHtmlTags() }
            .uniqueValues
            .map {
                SearchModelSection(
                    identifier: UUID().uuidString,
                    title: $0,
                    items: [],
                    expanded: false
                )
            }
    }
    
    private func mapItems(result: [FeedingPoint]) async -> [String : [SearchModelItem]] {
        await result.asyncReduce([String: [SearchModelItem]]()) { partialResult, point in
            var result = partialResult
            let item = SearchModelItem(
                identifier: point.id,
                name: point.localizedName.removeHtmlTags(),
                description: point.localizedDescription.removeHtmlTags(),
                icon: try? await dataService.getURL(key: point.cover),
                status: .init(point.status),
                category: .init(point.category.tag)
            )
            let city = point.localizedCity.removeHtmlTags()
            var items = result[city] ?? []
            items.append(item)
            result.updateValue(items, forKey: city)

            return result
        }
    }
}
