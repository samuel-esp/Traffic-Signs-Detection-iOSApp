//
//  Response.swift
//  TSD
//
//  Created by Samuel Esposito on /2312/20.
//

import Foundation

class  Response: Codable {
    
    let inference: String
    
    init(inference: String) {
        self.inference = inference
    }
    
    
}
