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
    
    var listener: NWListener!
    var connectionClients: [UUID: NWConnection] = [:]
    var clientsBuffer: [UUID: Data] = [:]
    let serverQueue = DispatchQueue(label: "serverQueue")
    let publisher = PassthroughSubject<(String?, String), Never>()
    
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
        
        listener.newConnectionHandler = { [weak self] newConnection in
            print("new! ")
            guard let self = self else { return }
            newConnection.start(queue: self.serverQueue)
            let uuid = UUID()
            self.clientsBuffer[uuid] = Data()
            self.connectionClients[uuid] = newConnection
            
            func receive() {
                newConnection.receive(minimumIncompleteLength: 1, maximumLength: 300
                )  { content, context, isComplete, error in
                    if let content = content {
                        self.checkBuffer(with: content, by: uuid)
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

    deinit {
        connectionClients.values.forEach{ $0.cancel()}
        connectionClients.removeAll()
        listener.newConnectionHandler = nil
        listener.cancel()
        listener = nil
        print("server dead")
    }

    func checkBuffer(with data: Data, by connection: UUID) {
        data.forEach {
            clientsBuffer[connection]?.append($0)
            if $0 == 125 {
                guard let  message = try? JSONDecoder().decode(Message.self, from: clientsBuffer[connection]!) else { return }
                var isComplete = false
                if message.text == "end" {
                    isComplete = true
                }
                send(by: connection, isComplete)
                sendToPublisher(with: message.idx+" : "+message.text)
                clientsBuffer[connection]?.removeAll()
            }
        }
    }
    
    func send(by uuid: UUID,_  isComplete: Bool = false ) {
        guard let data = clientsBuffer[uuid] else { return }
        for (sendinguuid, connection) in connectionClients {
            connection.send(content: data, completion: .contentProcessed({ error in
                if isComplete, sendinguuid == uuid {
                    self.removeClients(by: uuid)
                }
            }))
        }
    }
    
    func sendToPublisher(with text: String?) {
        publisher.send((text, String(connectionClients.count)))
    }
    
    func removeClients(by uuid: UUID)  {
        guard let connection = connectionClients[uuid] else { return }
        connection.cancel()
        connectionClients.removeValue(forKey: uuid)
        clientsBuffer.removeValue(forKey: uuid)
        sendToPublisher(with: nil)
    }
}
