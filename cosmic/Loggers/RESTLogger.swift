//
//  RESTLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 30/05/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public struct RESTLoggerConfig {
    let url: String
    let method: String
    
    init(url: String, method: String = "POST") {
        self.url = url
        self.method = method
    }
}

public class RESTLogger: LogReceiver {
    
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

    internal var sessionConfiguration = URLSessionConfiguration()
    
    internal var session: URLSession
    
    internal var config: RESTLoggerConfig?
    
    internal var cache: [String] = []
    
    required public init() {
        session = URLSession(configuration: sessionConfiguration)
    }
    
    convenience init(config: RESTLoggerConfig) {
        self.init()
        self.config = config
    }

    func onReceive(_ messages: [String], logLevel: LogLevel) {
        cache.append(contentsOf: messages)
        attemptSend()
    }
    
    func attemptSend() {
        
        guard let url = config?.url else { return }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = config?.method
        
        let cache = self.cache
        self.cache = []
        
        let messagesAsData = try? JSONSerialization.data(withJSONObject: cache, options: [])
        request.httpBody = messagesAsData
        
        
        let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
            
        }
        
        task.resume()
    }
    
}
