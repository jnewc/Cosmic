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
    var headers: [String: String]
    
    init(url: String, method: String = "POST", query: [String: String] = [:], headers: [String: String] = [:]) {
        self.url = url
        self.method = method
        self.query = query
        self.headers = headers
    }
    
    var urlWithQuery: String {
        let query = self.query.keys.map { "\($0)=\(self.query[$0]!)" }
        if query.count > 0 {
            return [ url, query.joined(separator: "&") ].joined(separator: "?")
        }
        return url
    }
}

public class HTTPLogger: Logger {
    
    // MARK: Logger properties
    
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
    
    /// A formatter for batching logs into single HTTP requests.
    /// Defaults to NewLineBatchFormatter
    internal var batchFormatter: BatchFormatter = NewLineBatchFormatter()
    
    internal var sessionConfiguration = URLSessionConfiguration.default
    
    internal var session: URLSession
    
    internal var config: HTTPLoggerConfig?
    // TODO: use LogCacheEntry
    internal var cache: [(String, LogMetadata)] = []
    
    required public init() {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(label: "com.cosmic.httplogger-\(UUID().uuidString)")
        session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: queue)
    }
    
    convenience init(config: HTTPLoggerConfig) {
        self.init()
        self.config = config
    }

    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        cache.append((message, metadata))
        attemptSend()
    }

    func attemptSend() {
        
        Debug.logger.debug("Attempting HTTP send with config: \(String(describing: config))")
        
        guard let url = config?.urlWithQuery else { return }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = config?.method
        
        if let headers = config?.headers {
            headers.keys.forEach { request.addValue(headers[$0]!, forHTTPHeaderField: $0) }
        }
        
        let cache = self.cache
        self.cache = []
        
        let body = batchFormatter.format(batch: cache)
        
        request.httpBody = body.data(using: .utf8)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
            error => Debug.logger.error(error!.localizedDescription)
            if let response = (response as? HTTPURLResponse) {
                Debug.logger.info("Status code: \(response.statusCode)")
            }
            
        }
        
        task.resume()
    }
    
}
