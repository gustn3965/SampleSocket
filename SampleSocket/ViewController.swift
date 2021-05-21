//
//  ViewController.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/18.
//

import UIKit

import Network

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeBottomConstraint: NSLayoutConstraint!
    
    var client: Client!
    let randomId = String(String(abs("hash".hashValue)).prefix(5))
    var data = [(String,String)]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.data.count-1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    // MARK: - Method 
    override func viewDidLoad() {
        super.viewDidLoad()
        client = Client(viewController: self, randomId: randomId)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.register(LeftCell.self, forCellReuseIdentifier: "leftCell")
        tableView.register(RightCell.self, forCellReuseIdentifier: "rightCell")
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchedView)))
    }
    
    @objc func touchedView() {
        self.view.endEditing(true)
    }
    
    @IBAction func clickSend() {
        guard let text = textField.text, !text.isEmpty else { return }
        client.send(textField.text!)
        textField.text?.removeAll()
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRetangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRetangle.height
            safeBottomConstraint.constant = 10+keyboardHeight
            bottomConstraint.constant = 10+keyboardHeight
            bottomConstraint.priority = .required
            safeBottomConstraint.priority = .defaultLow
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
                if self.data.count > 1 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.data.count-1, section: 0), at: .bottom, animated: true)
                }
            })
        }
    }
    
    @objc func keyboardWillDismiss(_ notification : Notification) {
        safeBottomConstraint.constant = 5
        bottomConstraint.constant = 5
        bottomConstraint.priority = .defaultLow
        safeBottomConstraint.priority = .required
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func touchExitButton() {
        client.exit()
    }
    
    @IBAction func touchResignButton() {
        client.exit()
        client = nil
        client = Client(viewController: self, randomId: randomId)
    }
}

// MARK: - TableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contexts = data[indexPath.row]
        let identifier: String = contexts.0 == randomId ? "rightCell" : "leftCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChatCell else { return UITableViewCell()}
        cell.setUpText(id: contexts.0, text: contexts.1)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}
