//
//  LeftCell.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/19.
//

import UIKit

class LeftCell: UITableViewCell, ChatCell {
    var stackView: UIStackView
    var idLabel =  UILabel()
    var contextLabel =  UILabel()
    let backView = UIView()
    
    // MARK: - Method 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        backView.addSubview(contextLabel)
        stackView = UIStackView(arrangedSubviews: [idLabel, backView])
        stackView.axis = .vertical
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
        constraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setView() {
        idLabel.textColor = .systemGray
        contextLabel.textColor = .black
        contextLabel.numberOfLines = 0
        stackView.frame = frame
        backView.clipsToBounds = true
        contentView.addSubview(stackView)
    }
    
    func constraint() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        contextLabel.translatesAutoresizingMaskIntoConstraints = false
        backView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        backView.setContentHuggingPriority(.defaultLow, for: .vertical)
        contextLabel.setContentHuggingPriority(.required, for: .horizontal)
        contextLabel.setContentHuggingPriority(.required, for: .vertical)

        NSLayoutConstraint.activate(
            [contextLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 5),
             contextLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -5),
             contextLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 5),
             contextLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -5)])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
             stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
             stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)])
    }
    
    override func draw(_ rect: CGRect) {
        backView.layer.cornerRadius = backView.frame.height / 3
    }
    
    func setUpText(id: String, text: String) {
        idLabel.text = id
        contextLabel.text = text
        stackView.alignment = .leading
        backView.backgroundColor =  #colorLiteral(red: 0.87, green: 0.54, blue: 0.44, alpha: 1.00)
    }
}
