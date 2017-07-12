//
//  SocketLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation
import Socket

public struct SocketLoggerConfig {
    let transport: UniversalSocketTransport
    let host: String
    let port: Int32
    
    public init(host: String, port: Int32, transport: UniversalSocketTransport) {
        self.host = host
        self.port = port
        self.transport = transport
    }
}

public class SocketLogger: NSObject, LogReceiver {
    
    public var logLevel: LogLevel = .info
    
    public var formatters: [LogFormatter] = []
    
    internal var socket: UniversalSocket?

    internal let queue = DispatchQueue(label: "cosmic.socket")
    
    private var cache: [String] = []
    
    /// Configurable name of sender; usually the name or bundle ID of
    /// the calling application.
    public var senderName: String = ""
    
    public var config: SocketLoggerConfig?
    
    override public required init() {
        super.init()
    }
    
    convenience public init(config: SocketLoggerConfig) {
        self.init()
        self.config = config
        
        self.socket = try? UniversalSocket(config: config)
    }
    
    func onReceive(_ messages: [String], logLevel: LogLevel) {
        cache.append(contentsOf: messages)
        attemptSend()
    }
    
    // MARK : Internal logging
    
    private func attemptSend() {
        if !cache.isEmpty {
            let message =  format(message: cache.removeFirst())
            if let data = message.data(using: .utf8) {
                send(data: data)
            }
            if !cache.isEmpty {
                // TODO FIXME : on what thread should this be dispatched
                DispatchQueue.main.async { self.attemptSend() }
            }
        }
    }
    
    private func send(data: Data) {
        do {
            
            guard let socket = socket else {
                Debug.logger.error("Socket is nil")
                return
            }
            
            if !socket.isConnected {
                try socket.connect()
            }
            
            try socket.send(data: data)

        } catch let e as Socket.Error {
            Debug.logger.error(
                "Attempt connect failed for \(config?.host ?? "UnknownHost"):\(config?.port ?? 0)",
                " - reason: \(e.errorReason ?? "Unknown")",
                " - code:   \(e.errorCode)"
            )
        } catch let e {
            Debug.logger.error("Unknown error attempting to connect: \(e.localizedDescription)")
        }
    }
    
}
