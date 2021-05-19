//
//  Client.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/19.
//

import Foundation
import Network

class Client {

    var connection = NWConnection(host: "172.30.1.33", port: 8080, using: .tcp)
    var queue = DispatchQueue.init(label: "ClientQueue")
    var randomId: String
    weak var viewController: ViewController!
    
    init(viewController: ViewController, randomId: String ) {
        self.viewController = viewController
        self.randomId = randomId
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("I'm ready")
                self.send("👋 Hi, I entered!")
            case .waiting(let error):
                print(error)
            case .failed(_):
                self.connection.cancel()
                print("fail")
            case .cancelled:
                self.connection.cancel()
                print("cancled")
            case .preparing:
                print("preparing")
            case .setup:
                print("setup")
                
            @unknown default:
                print()
            }
        }
        connection.start(queue: queue)
    }
    
    func send(_ text: String) {
        let data = randomId + "-" + text
        connection.send(content: data.data(using: .utf8),
                        completion: .contentProcessed({ error in
            if let error = error {
                print(error)
            }
            self.receive()
        }))
    }
    
    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 300
        ) { content, context, isComplete, error in
            if content != nil {
                let data = String(data: content!, encoding: .utf8)!
                    .split(separator: "-").map{String($0)}
                let id = data[0]
                var text = data[1]
                
                if text == "end" {
                    text = "-- 🖐 Bye! --"
                    if id == self.randomId {
                        self.viewController.data.append((id,text))
                        self.connection.cancel()
                        return
                    }
                }
                self.viewController.data.append((id,text))
                self.receive()
            }
        }
    }
    
    func exit() {
        send("end")
        
    }
}
