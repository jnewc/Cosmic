//
//  LogzLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 11/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

struct LogzServiceConfig {
    
    
    static let method        = "POST"

    static let httpUri      = "http://listener.logz.io:8070"
    
    static let httpsUri     = "https://listener.logz.io:8071"
    
    static let tokenKey     = "token"
    
    static let typeKey      = "type"
    
}


/// Sends logs to Logz.io
public class LogzLogger: HTTPLogger {

    var defaultFields = [
        "Sender": "Cosmic"
    ]
    
    public required init() {
        super.init()

        
        // Each log is transmitted as an atomic JSON string
        // NOTE: Avoid pretty-printing options and ensure that
        // it does not contain newlines
        let jsonFormatter = JSONFormatter { message in
            // TODO: allow configuration of fields
            return [
                "created": Date().iso8601,
                "message": message
            ]
        }
        formatters.append(jsonFormatter)
        
    }
    
    public convenience init(withToken loggingToken: String) {
        self.init()
        self.config = HTTPLoggerConfig(
            url: LogzServiceConfig.httpsUri,
            method: LogzServiceConfig.method,
            query: [
                LogzServiceConfig.tokenKey: loggingToken,
                LogzServiceConfig.typeKey: logLevel.simpleName
            ]
        )
    }
    
    public var sslEnabled: Bool = true {
        didSet {
            if sslEnabled {
                config?.url = LogzServiceConfig.httpsUri
            } else {
                config?.url = LogzServiceConfig.httpUri
            }
        }
    }
    
    override public var logLevel: LogLevel {
        didSet {
            config?.query[LogzServiceConfig.typeKey] = logLevel.simpleName
        }
    }
}
