import Foundation

public protocol SearchViewItem {
    var identifier: String { get }
    var cellReuseIdentifier: String { get }
    var cellType: SearchCellContainable.Type { get }
    var cellSizerType: SearchCellSizer.Type { get }

    func hash(into hasher: inout Hasher)
    func isEqual(to anotherItem: SearchViewItem) -> Bool
}
