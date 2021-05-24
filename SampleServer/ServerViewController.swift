//
//  ViewController.swift
//  SampleServer
//
//  Created by hyunsu on 2021/05/21.
//

import UIKit
import Combine
class ServerViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var count: UILabel!
    
    var textCancellable: AnyCancellable?
    var texts: String = ""
    var server: Server?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        server = Server()
        textCancellable = server?.publisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (text, count) in
                if let text = text {
                    self.textView.text.append("\n"+text)
                }
                self.count.text = "count: \(count)"
                self.scrollDown()
            })
    }

    func scrollDown() {
        let contentHeight = self.textView.contentSize.height
        let height = self.textView.bounds.height
        self.textView.scrollRectToVisible(CGRect(x: 0, y: contentHeight - height , width: self.textView.bounds.width, height: height), animated: true)
    }
}

