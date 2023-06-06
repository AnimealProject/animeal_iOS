//
//  AMURLSessionDelegate.swift
//  animeal
//
//  Created by Mikhail Churbanov on 5/17/23.
//

import Foundation
import AWSAPIPlugin

public typealias AuthChallengeDispositionHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

class AMURLSessionDelegate: NSObject {
    
    private let amplifyDelegate: URLSessionBehaviorDelegate?

    private var responseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
        return formatter
    }()

    init(amplifyDelegate: URLSessionBehaviorDelegate?) {
        self.amplifyDelegate = amplifyDelegate
    }
}

// MARK: - Server time extraction from headers

extension AMURLSessionDelegate: URLSessionDataDelegate {

    @objc public func urlSession(_ session: URLSession,
                                 dataTask: URLSessionDataTask,
                                 didReceive data: Data) {

        let httpResponse = dataTask.response as? HTTPURLResponse
        if let serverDateString = httpResponse?.value(forHTTPHeaderField: "date"),
           let serverDate = responseDateFormatter.date(from: serverDateString) {
            NetTime.serverTimeDifference = Date.now.timeIntervalSince(serverDate)
            NetTime.serverNow = serverDate
        }

        // Pass further to amplify default handler
        amplifyDelegate?.urlSessionBehavior(session,
                                            dataTaskBehavior: dataTask,
                                            didReceive: data)
    }
}

// MARK: - Default handling of other required methods

extension AMURLSessionDelegate: URLSessionDelegate {

    @objc public func urlSession(_ session: URLSession,
                                 didReceive challenge: URLAuthenticationChallenge,
                                 completionHandler: @escaping AuthChallengeDispositionHandler) {

        completionHandler(.performDefaultHandling, nil)
    }
}

extension AMURLSessionDelegate: URLSessionTaskDelegate {

    @objc public func urlSession(_ session: URLSession,
                                 task: URLSessionTask,
                                 didReceive challenge: URLAuthenticationChallenge,
                                 completionHandler: @escaping AuthChallengeDispositionHandler) {

        completionHandler(.performDefaultHandling, nil)
    }

    @objc public func urlSession(_ session: URLSession,
                                 task: URLSessionTask,
                                 didCompleteWithError error: Error?) {

        amplifyDelegate?.urlSessionBehavior(
            session,
            dataTaskBehavior: task,
            didCompleteWithError: error
        )
    }
}
