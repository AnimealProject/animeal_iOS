import Foundation

public extension DispatchQueue {
    private static var _onceTracker: [String] = []

    /**
     Executes a block of code, associated with a auto generate unique token by file name + fuction name + line of code, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
    */
    static func once(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        completion: () -> Void
    ) {
        let token = "\(file):\(function):\(line)"
        once(token: token, completion: completion)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter completion: Completion to execute once
     */
    static func once(
        token: String,
        completion: () -> Void
    ) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        guard !_onceTracker.contains(token) else { return }
        _onceTracker.append(token)
        completion()
    }
}
