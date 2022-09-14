import Foundation

protocol Starting {
    @MainActor
    func start()
}

protocol Stopable {
    @MainActor
    func stop()
}

protocol Coordinatable: Starting, Stopable { }
