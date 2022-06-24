import CocoaLumberjack
import UIKit
import CocoaLumberjackSwift
import FirebaseCrashlytics

public protocol DevLoggerServiceHolder {
    var devLoggerService: DevLoggerService { get }
}

public enum DebugAdditionalLogger {
    case crashlytics
}

// swiftlint:disable function_parameter_count
public protocol DevLoggerService {
    static func logMessage(
        _ message: @autoclosure () -> Any,
        level: DDLogLevel,
        flag: DDLogFlag,
        context: Int,
        file: StaticString,
        function: StaticString,
        line: UInt,
        tag: Any?,
        asynchronous: Bool
    )

    static func logFatalError(
        _ message: @autoclosure () -> String,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) -> Never
}

public protocol Logger {
    func debug(_ message: @autoclosure () -> String)
    func info(_ message: @autoclosure () -> String)
    func warning(_ message: @autoclosure () -> String)
    func verbose(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

public extension DevLoggerService {
    private static func formatMessage(
        level: DDLogLevel,
        _ message: @autoclosure () -> String
    ) -> String {
        let message = message()
            .replacingOccurrences(of: "\r", with: "\r*", options: .caseInsensitive, range: nil)
            .replacingOccurrences(of: "\r ", with: "\r* ", options: .caseInsensitive, range: nil)
        let lvlString: String
        switch level {
        case .debug: lvlString = "[DEBUG]"
        case .info: lvlString = "[INFO]"
        case .warning: lvlString = "[WARNING]"
        case .error: lvlString = "[ERROR]"
        case .all: lvlString = "[ALL]"
        case .verbose: lvlString = "[VERBOSE]"
        case .off: lvlString = "[OFF]"
        @unknown default:
            fatalError("Can't handle provided level")
        }
        return lvlString + " " + message
    }

    static func logMessage(
        _ message: @autoclosure () -> Any,
        level: DDLogLevel,
        flag: DDLogFlag,
        context: Int,
        file: StaticString,
        function: StaticString,
        line: UInt,
        tag: Any?,
        asynchronous: Bool
    ) {
        switch level {
        case .debug:
            logCLSMessage("\(message())", additionalLoggers: [DebugAdditionalLogger.crashlytics])
        case .error:
            logCLSMessage("\(message())", additionalLoggers: [DebugAdditionalLogger.crashlytics])
            let error = makeNSError(prefix: "ERROR", file: file, function: function, message: "\(message())")
            Crashlytics.crashlytics().record(error: error)
        case .warning:
            logCLSMessage("\(message())", additionalLoggers: [DebugAdditionalLogger.crashlytics])
            let error = makeNSError(prefix: "WARNING", file: file, function: function, message: "\(message())")
            Crashlytics.crashlytics().record(error: error)
        default:
            break
        }
        _DDLogMessage(
            Self.formatMessage(level: level, "\(message())"),
            level: level,
            flag: flag,
            context: context,
            file: file,
            function: function,
            line: line,
            tag: tag,
            asynchronous: asynchronous,
            ddlog: DDLog.sharedInstance
        )
    }

    static func logFatalError(
        _ message: @autoclosure () -> String,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) -> Never {
        #if !DEBUG
            let error = DevLoggerImplementation.makeNSError(
                prefix: "FATAL",
                file: file,
                function: function,
                message: "💥 \(message())"
            )
            Crashlytics.crashlytics().record(error: error)
        #endif
            return Swift.fatalError(message(), file: file, line: line)
    }

    static private func logCLSMessage(_ message: @autoclosure () -> String, additionalLoggers: [DebugAdditionalLogger]) {
        for logger in additionalLoggers {
            switch logger {
            case .crashlytics:
                Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([message()]))
            }
        }
    }

    static private func makeNSError(prefix: String, file: StaticString, function: StaticString, message: String) -> NSError {
        let fileString = "\(file)"
        let lastElement = fileString.components(separatedBy: "/").last ?? fileString
        let fileName: String
        if let swiftRange = lastElement.range(of: ".swift") {
            fileName = String(lastElement[..<swiftRange.lowerBound])
        } else {
            fileName = lastElement
        }
        let errorDomain: String = "\(prefix)\(fileName).\(function)"
        let userInfo = ["message": message]
        return NSError(domain: errorDomain, code: errorDomain.hashValue, userInfo: userInfo)
    }
}

// MARK: - ApplicationService

public final class DevLoggerImplementation: DevLoggerService, ApplicationDelegateService {
    public init() {}

    public func registerApplication(_: UIApplication, didFinishLaunchingWithOptions _: [AnyHashable: Any]?) -> Bool {
        guard DDLog.allLoggers.isEmpty else {
            return true
        }

        // Prepare file logger
        let fileLogger = DDFileLogger()
        fileLogger.maximumFileSize = 5 * 1024 * 1024 // 5 Megabytes
        fileLogger.rollingFrequency = 3 * 24 * 60 * 60 // 3 days
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7

        // Add file logger
        DDLog.add(fileLogger)

        // DDOSLogger works around os_log
        DDLog.add(DDOSLogger.sharedInstance)

        return true
    }

    public func applicationWillTerminate(_: UIApplication) {
        DDLog.removeAllLoggers()
    }
}
// swiftlint:enable function_parameter_count
