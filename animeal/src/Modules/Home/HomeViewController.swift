import UIKit
import Style
import MapboxMaps


// MARK: - MapView usage example
class HomeViewController: UIViewController {
    private var mapView: MapView!
    private var cameraLocationConsumer: CameraLocationConsumer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.location.options.puckType = .puck2D()

        cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) {[weak self] _ in
            guard let self = self else { return }
             // Register the location consumer with the map
             // Note that the location manager holds weak references to consumers, which should be retained
            self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
        }
    }

    public func mapInitOptions() -> MapInitOptions {
        let resourceOptions = ResourceOptions(
            accessToken: ResourceOptionsManager.default.resourceOptions.accessToken
        )

        return MapInitOptions(
            resourceOptions: resourceOptions,
            styleURI: .light
        )
    }
}

public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?

    init(mapView: MapView) {
        self.mapView = mapView
    }

    public func locationUpdate(newLocation: MapboxMaps.Location) {
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 0.3)
    }
}
