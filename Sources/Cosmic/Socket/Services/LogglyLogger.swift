//
//  LogglyLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 21/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

struct LogglyServiceConfig {
    
    static let method = "POST"
    
    static let url = "https://logs-01.loggly.com/inputs/$(TOKEN)/tag/http/"
    
}

public class LogglyLogger: HTTPLogger {
    
    var token: String? {
        didSet {
            if let token = self.token {
                config = HTTPLoggerConfig(
                    url: LogglyServiceConfig.url.replacingOccurrences(of: "$(TOKEN)", with: token),
                    method: LogglyServiceConfig.method,
                    query: [:],
                    headers: [ HTTPHeader.ContentType: HTTPHeader.ContentTypeJSON ]
                )
            }
        }
    }
    
    public required init() {
        super.init()
    }
    
    public convenience init(token: String?) {
        self.init()
        
        ({ self.token = token })()
        
        batchFormatter = JSONBatchFormatter(converter: { message -> [String : Any] in
            return [
                "timestamp": Date().iso8601,
                "message": message
            ]
        })
        
    }
    
}
