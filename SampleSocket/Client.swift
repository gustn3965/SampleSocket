//
//  Client.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/19.
//

import Foundation
import Network

class Client {

    let connection = NWConnection(host: "172.30.1.28", port: 8088, using: .tcp)
    let queue = DispatchQueue.init(label: "ClientQueue")
    var randomId: String
    weak var viewController: ViewController!

    // MARK: - Method 
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
//        let data = (randomId + "-" + text).data(using: .utf8)
        let data = try? JSONEncoder().encode(Messages(messages: [Message(idx: randomId, text: text, date: Date())]))
        print(data)
        connection.send(content: data,
                        completion: .contentProcessed({ error in
            if let error = error {
                print(error)
            }
        }))
        self.receive()
    }
    
    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 300
        ) { content, context, isComplete, error in
            if content != nil {
                let data = try? JSONDecoder().decode(Messages.self, from: content!)
                print(data?.messages.count)
                data?.messages.forEach {
                    if $0.text == "end" {
                        if $0.idx == self.randomId {
                            self.viewController.data.append(($0.idx, "-- 🖐 Bye! --"))
                            self.connection.cancel()
                            return
                        }
                    }
                    self.viewController.data.append(($0.idx, $0.text))
                }
                self.receive()
            }
            if error != nil  {
                print("receive error is ", error! )
            }
        }
    }
    
    func exit() {
        send("end")
        
    }
}
