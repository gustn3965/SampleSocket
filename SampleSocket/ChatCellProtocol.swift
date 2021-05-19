//
//  ChatCellProtocol.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/19.
//

import UIKit

protocol ChatCell where Self:UITableViewCell {
    func setUpText(id: String, text: String)
}
