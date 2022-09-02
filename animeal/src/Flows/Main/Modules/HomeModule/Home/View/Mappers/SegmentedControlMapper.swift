import Foundation
import Style
import UIComponents
import CoreLocation

// sourcery: AutoMockable
protocol FilterViewMappable {
    func mapFilterModel(_ input: [HomeModel.FilterItem]) -> FilterModel
}

final class SegmentedControlMapper: FilterViewMappable {
    func mapFilterModel(_ input: [HomeModel.FilterItem]) -> FilterModel {
        let items = input.map { segment in
            SegmentedControl.Item(
                identifier: segment.identifier.rawValue,
                title: segment.title,
                isSelected: segment.isSelected
            )
        }
        return FilterModel(segmentedControlModel: SegmentedControl.Model(items: items))
    }
}

struct FilterModel {
    let segmentedControlModel: SegmentedControl.Model
}
