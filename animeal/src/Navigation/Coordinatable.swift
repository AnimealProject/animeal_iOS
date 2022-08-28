import Foundation

protocol Starting {
    func start()
}

protocol Stopable {
    func stop()
}

protocol Coordinatable: Starting, Stopable { }
