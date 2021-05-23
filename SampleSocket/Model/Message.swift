//
//  Message.swift
//  SampleSocket
//
//  Created by hyunsu on 2021/05/23.
//

import Foundation

struct Message: Codable {
    var idx: String
    var text: String
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case idx, text, date 
    }
}
