//
//  PapertrailLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 21/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


/// A logger for the Papertrail logging service.
///
/// The socket should be configured using the destination
/// details found here: 
/// https://papertrailapp.com/account/destinations
///
/// Example:
///
///     let config = SocketLoggerConfig(
///         host: "logs1.papertrailapp.com", 
///         port: 12345
///     )
///     let formatter = PapertrailLogger(config: config)
///
public class PapertrailLogger: SocketLogger {
    
    let syslogFormatter = SyslogFormatter()
    
    public required init() {
        super.init()
        formatters.append(syslogFormatter)
    }
    
}
