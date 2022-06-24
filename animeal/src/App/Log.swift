import Foundation
import Services

public final class Log: Services.Logger {
    static let shared = Log()

    public func debug(_ message: @autoclosure () -> String) {
        logDebug(message())
    }

    public func info(_ message: @autoclosure () -> String) {
        logInfo(message())
    }

    public func warning(_ message: @autoclosure () -> String) {
        logWarning(message())
    }

    public func verbose(_ message: @autoclosure () -> String) {
        logVerbose(message())
    }

    public func error(_ message: @autoclosure () -> String) {
        logError(message())
    }

    /// Logs a fatal error. The error is unrecovarable and the app should crash.
    public static func fatalError(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> Never {
        return DevLoggerImplementation.logFatalError(message(), file: file, function: function, line: line)
    }
}

public func logDebug(
    _ message: @autoclosure () -> String,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    tag: AnyObject? = nil,
    asynchronous async: Bool = false
) {
    DevLoggerImplementation.logMessage(
        message(),
        level: .debug,
        flag: .debug,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: tag,
        asynchronous: async
    )
}

public func logInfo(
    _ message: @autoclosure () -> String,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    tag: AnyObject? = nil,
    asynchronous async: Bool = false
) {
    DevLoggerImplementation.logMessage(
        message(),
        level: .info,
        flag: .info,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: tag,
        asynchronous: async
    )
}

public func logWarning(
    _ message: @autoclosure () -> String,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    tag: AnyObject? = nil,
    asynchronous async: Bool = false
) {
    DevLoggerImplementation.logMessage(
        message(),
        level: .warning,
        flag: .warning,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: tag,
        asynchronous: async
    )
}

public func logVerbose(
    _ message: @autoclosure () -> String,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    tag: AnyObject? = nil,
    asynchronous async: Bool = false
) {
    DevLoggerImplementation.logMessage(
        message(),
        level: .verbose,
        flag: .verbose,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: tag,
        asynchronous: async
    )
}

public func logError(
    _ message: @autoclosure () -> String,
    context: Int = 0,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line,
    tag: AnyObject? = nil,
    asynchronous async: Bool = false
) {
    DevLoggerImplementation.logMessage(
        message(),
        level: .error,
        flag: .error,
        context: context,
        file: file,
        function: function,
        line: line,
        tag: tag,
        asynchronous: async
    )
}
