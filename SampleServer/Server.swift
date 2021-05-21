//
//  Server.swift
//  SampleServer
//
//  Created by hyunsu on 2021/05/21.
//

import Foundation
import Network
import Combine

class Server {
    
    var listener: NWListener
    var connectionClients: [(NWConnection)] = []
    let serverQueue = DispatchQueue(label: "serverQueue")
    
    let publisher = PassthroughSubject<String, Never>()
    
    // MARK: - Method
    init() {
        listener = try! NWListener(using: .tcp, on: 8088)
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready: print("ready")
            case .failed(let error): print("error: ",error)
            case .cancelled: print("cacneld")
            case .setup: print("setup")
            default: print()
            }
        }
        
        listener.newConnectionHandler = { newConnection in
            print("new! ")
            newConnection.start(queue: self.serverQueue)
            self.connectionClients.append(newConnection)
            
            func receive() {
                newConnection.receive(minimumIncompleteLength: 1, maximumLength: 300
                )  { content, context, isComplete, error in
                    if let data = content {
                        let data = String(data: data, encoding: .utf8)!
                            .split(separator: "-").map{String($0)}
                        let id = data[0]
                        let text = data[1]
                        self.sendToPublisher(with: id+" : "+text)
                        self.send(message: content!)
                    }
                    if error == nil {
                        receive()
                    }
                }
            }
            receive()
            
        }
        listener.start(queue: serverQueue)
    }
    
    func sendToPublisher(with text: String) {
        publisher.send(text)
    }
    
    func send(message: Data) {
        for connection in self.connectionClients {
            connection.send(content: message, completion: .contentProcessed({ error in
                if let error = error {
                    print(error)
                }
            }))
        }
    }
}
