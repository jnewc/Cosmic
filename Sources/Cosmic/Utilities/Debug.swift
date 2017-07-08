//
//  Debug.swift
//  Cosmic
//
//  Created by Jack Newcombe on 27/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

internal final class Debug {
    
    static var logger: Logger = {
        let logger = CompositeLogger()
#if DEBUG
        let printLogger = PrintLogger()
        printLogger.prefix = "✨Cosmic✨"
        printLogger.logLevel = .debug
        logger.loggers.append(printLogger)
#endif
        return logger
    }()
    
}
