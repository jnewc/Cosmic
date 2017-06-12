//
//  HTTPLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 30/05/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public struct HTTPLoggerConfig {
    var url: String
    var method: String
    var query: [String: String]
    
    init(url: String, method: String = "POST", query: [String: String] = [:]) {
        self.url = url
        self.method = method
        self.query = query
    }
    
    var urlWithQuery: String {
        let query = self.query.keys.map { "\($0)=\(self.query[$0]!)" }
        if query.count > 0 {
            return [ url, query.joined(separator: "&") ].joined(separator: "?")
        }
        return url
    }
}

public class HTTPLogger: LogReceiver {
    
    // MARK: LogReceiver properties
    
    /// A list of formatters to apply to logs
    ///
    /// Formatters transform logs from one string-based representation to another. Each
    /// formatter will be applied to every message, so any filtering should be done 
    /// within the formatter itself.
    public var formatters: [LogFormatter] = []
    
    /// Indicates the current level of logging.
    ///
    /// The log level of a Logger indicates:
    ///  - The class of logs that should be logged
    ///  - The classes of augmentation that should be applied to logs
    public var logLevel: LogLevel = .info

    // MARK: HTTPLogger properties
    
    internal var batchFormatter: BatchFormatter = NewLineBatchFormatter()
    
    internal var sessionConfiguration = URLSessionConfiguration.default
    
    internal var session: URLSession
    
    internal var config: HTTPLoggerConfig?
    
    internal var cache: [String] = []
    
    required public init() {
        session = URLSession(configuration: sessionConfiguration)
    }
    
    convenience init(config: HTTPLoggerConfig) {
        self.init()
        self.config = config
    }

    func onReceive(_ messages: [String], logLevel: LogLevel) {
        cache.append(contentsOf: messages)
        attemptSend()
    }
    
    func attemptSend() {
        
        guard let url = config?.urlWithQuery else { return }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = config?.method
        
        let cache = self.cache.map { self.format(message: $0) }
        self.cache = []
        
        let body = batchFormatter.format(batch: cache)
        
        request.httpBody = body.data(using: .utf8)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
            print("Logz Response: \(response)")
            if let data = data {
                print(String(data: data, encoding: .utf8))
            }
        }
        
        task.resume()
    }
    
}
