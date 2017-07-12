//
//  UniversalSocket.swift
//  Cosmic
//
//  Created by Jack Newcombe on 09/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation
import Socket

public enum UniversalSocketTransport {
    case udp
    case tcp
}

class UniversalSocket {
    
    let socket: Socket
    
    let config: SocketLoggerConfig
    
    let readQueue = DispatchQueue(uniqueWithLabel: "com.cosmic.socketread")
    
    init(config: SocketLoggerConfig, useIPV6: Bool = false) throws {
        
        self.config = config
        
        let family: Socket.ProtocolFamily = useIPV6 ? .inet6 : .inet
        
        switch config.transport {
        case .udp:
            self.socket = try Socket.create(family: family, type: .datagram, proto: .udp)
        case .tcp:
            self.socket = try Socket.create(family: family, type: .stream, proto: .tcp)
        }
    }
    
    func connect() throws {
        
        try forProtocol(.tcp) {
            try self.socket.connect(to: config.host, port: config.port)
        }
        
    }
    
    func listen() throws {
        try forProtocol(.tcp) {
            try self.socket.listen(on: Int(self.config.port))
        }
    }
    
    func send(data: Data) throws {
        
        try forProtocol(.udp) {
            if let address = Socket.createAddress(for: config.host, on: config.port) {
                let _ = try socket.write(from: data, to: address)
            }
        }

        try forProtocol(.tcp) {
            let _ = try socket.write(from: data)
        }
        
    }
    
    func read(completion: @escaping (Data) -> ()) {
        
        readQueue.async {
            
            var data: Data = Data()
        
            try? self.forProtocol(.udp) {
                let _ = try? self.socket.listen(
                    forMessage: &data,
                    on: Int(self.config.port)
                )
                completion(data)
            }
            
            try? self.forProtocol(.tcp) {
                let readSocket = try? self.socket.acceptClientConnection()
                let _ = try? readSocket?.read(into: &data)
                completion(data)
            }
            
        }
    }
    
    var isConnected: Bool {
        if let proto = socket.signature?.proto {
            switch proto {
            case .udp:
                return true
            case .tcp:
                return socket.isConnected
            default:
                return false
            }
        }
        
        return false
    }
    
    func forProtocol(_ proto: Socket.SocketProtocol, _ callback: () throws -> ()) throws {
        if let currentProto = socket.signature?.proto, currentProto == proto {
            try callback()
        }
    }
    
}
