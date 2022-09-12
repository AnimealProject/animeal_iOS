import UIKit

// MARK: - View
protocol ___VARIABLE_productName:identifier___Viewable: AnyObject {
}

// MARK: - ViewModel
typealias ___VARIABLE_productName:identifier___ViewModelProtocol = ___VARIABLE_productName:identifier___ViewModelLifeCycle
    & ___VARIABLE_productName:identifier___ViewInteraction
    & ___VARIABLE_productName:identifier___ViewState

protocol ___VARIABLE_productName:identifier___ViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol ___VARIABLE_productName:identifier___ViewInteraction: AnyObject {
}

protocol ___VARIABLE_productName:identifier___ViewState: AnyObject {
}

// MARK: - Model

// sourcery: AutoMockable
protocol ___VARIABLE_productName:identifier___ModelProtocol: AnyObject {
}
