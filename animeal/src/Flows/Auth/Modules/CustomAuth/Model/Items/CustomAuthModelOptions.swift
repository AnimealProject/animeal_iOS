import Foundation

struct CustomAuthModelOptions: OptionSet {
    let rawValue: Int
    static let passwordless = CustomAuthModelOptions(rawValue: 1 << 0)
    static let all: CustomAuthModelOptions = [.passwordless]
}
