import Testing
import UIKit
import ObjectiveC
@testable import animeal

struct ScreenAccessibleTests {
    @Test("Every screen declares an identifier")
    func everyScreenDeclaresIdentifier() {
        let missing = appScreenClasses()
            .filter { !($0 is any ScreenAccessible.Type) }
            .map { NSStringFromClass($0) }
            .sorted()

        #expect(missing.isEmpty, "Screens without an accessibility identifier: \(missing)")
    }
}

private func appScreenClasses() -> [UIViewController.Type] {
    let expectedImage = class_getImageName(LoginViewController.self)
    let numberOfClasses = Int(objc_getClassList(nil, 0))
    guard numberOfClasses > 0 else { return [] }

    let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
    let autoreleasingPointer = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
    objc_getClassList(autoreleasingPointer, Int32(numberOfClasses))
    defer { classesPtr.deallocate() }

    return (0..<numberOfClasses).compactMap { index in
        let cls: AnyClass = classesPtr[index]
        guard let imageName = class_getImageName(cls),
              let expectedImage,
              strcmp(imageName, expectedImage) == 0 else {
            return nil
        }
        guard String(reflecting: cls).hasPrefix("animeal.") else { return nil }
        guard isSubclass(cls, of: UIViewController.self) else { return nil }
        return unsafeBitCast(cls, to: UIViewController.Type.self)
    }
}

private func isSubclass(_ cls: AnyClass, of parent: AnyClass) -> Bool {
    var current: AnyClass? = class_getSuperclass(cls)
    while let candidate = current {
        if candidate == parent {
            return true
        }
        current = class_getSuperclass(candidate)
    }
    return false
}
