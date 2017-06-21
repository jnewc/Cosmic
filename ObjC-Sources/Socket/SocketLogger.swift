//
//  SocketLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public struct SocketLoggerConfig {
    let host: String
    let port: UInt16
    
    public init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
}

public class SocketLogger: NSObject, LogReceiver, GCDAsyncUdpSocketDelegate {
    
    public var logLevel: LogLevel = .info
    
    public var formatters: [LogFormatter] = []
    
    let socket = GCDAsyncUdpSocket()

    private let queue = DispatchQueue(label: "cosmic.socket")
    
    private var cache: [String] = []
    
    /// Configurable name of sender; usually the name or bundle ID of
    /// the calling application.
    public var senderName: String = "Application"
    
    public var config: SocketLoggerConfig?
    
    override public required init() {
        super.init()
        socket.setDelegate(self)
        socket.setDelegateQueue(queue)
    }
    
    convenience public init(config: SocketLoggerConfig) {
        self.init()
        self.config = config
        attemptConnect()
    }
    
    func onReceive(_ messages: [String], logLevel: LogLevel) {
        cache.append(contentsOf: messages)
        attemptSend()
    }
    
    // MARK : Internal logging
    
    private func attemptSend() {
        if socket.isConnected() && !cache.isEmpty {
            let message =  format(message: cache.removeFirst())
            if let data = message.data(using: .utf8) {
                socket.send(data, withTimeout: 1.0, tag: 0)
            }
            if !cache.isEmpty {
                // TODO FIXME : on what thread should this be dispatched
                DispatchQueue.main.async { self.attemptSend() }
            }
        } else {
            attemptConnect()
        }
    }
    
    private func attemptConnect() {
        if let config = config {
            try? socket.connect(toHost: config.host, onPort: config.port)
        }
    }
    
    // MARK: Socket delegate
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("SOCKET: Did connect")
        attemptSend()
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("SOCKET: Error - \(error?.localizedDescription ?? "Unknown")")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("SOCKET: Data sent")
    }
}
