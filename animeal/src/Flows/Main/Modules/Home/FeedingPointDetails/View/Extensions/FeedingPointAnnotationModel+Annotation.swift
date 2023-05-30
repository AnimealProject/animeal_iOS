import MapboxMaps
import UIComponents
import UIKit
import Style

public extension FeedingPointAnnotationModel {
    func selectionAnnotation(for radius: CLLocationDistance, at coordinates: CLLocationCoordinate2D) -> Annotation {
        let polygon = Polygon(center: coordinates, radius: radius, vertices: 64)
        var annotation = PolygonAnnotation(id: identifier, polygon: polygon)
        annotation.fillColor = .init(Asset.Colors.carminePink.color)
        annotation.fillOpacity = 0.2
        annotation.fillOutlineColor = .init(Asset.Colors.carminePink.color.withAlphaComponent(0.32))
        return annotation
    }
    
    func annotation(at coordinates: CLLocationCoordinate2D) -> Annotation {
        var annotation = PointAnnotation(id: identifier, coordinate: coordinates)
        annotation.image = .init(image: image, name: "\(kind)")
        annotation.iconAnchor = .center
        return annotation
    }
}

extension FeedingPointAnnotationModel {
    var image: UIImage {
        switch (kind, hungerLevel) {
        case (.dog, .high): return Asset.Images.dogHungryHigh.image
        case (.dog, .medium): return Asset.Images.dogHungryMedium.image
        case (.dog, .low): return Asset.Images.dogHungryLow.image
            
        case (.cat, .high): return Asset.Images.catHungryHigh.image
        case (.cat, .medium): return Asset.Images.catHungryMedium.image
        case (.cat, .low): return Asset.Images.catHungryLow.image
            
        case (.fav, .high): return Asset.Images.favouriteHungryHigh.image
        case (.fav, .medium): return Asset.Images.favouriteHungryMedium.image
        case (.fav, .low): return Asset.Images.favouriteHungryLow.image
        }
    }
}

