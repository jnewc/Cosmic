//
//  LogItLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 12/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

fileprivate struct LogItServiceConfig {
    
    static let method               = "POST"
    
    static let httpsUri             = "https://api.logit.io/v2"
    
    static let headerApiKeyName     = "ApiKey"
    
    static let headerLogTypeName    = "LogType"
    
}

class LogItLogger: HTTPLogger {
    
    var apiKey: String?
    
    public required init() {
        super.init()

    }
    
    public convenience init(withKey apiKey: String) {
        self.init()
        
        config = HTTPLoggerConfig(
            url: LogItServiceConfig.httpsUri,
            method: LogItServiceConfig.method
        )
        
        config?.headers = [
            LogItServiceConfig.headerApiKeyName: apiKey,
            HTTPHeader.ContentType: HTTPHeader.ContentTypeJSON,
            LogItServiceConfig.headerLogTypeName: logLevel.simpleName
        ]
    
    }
    
}
