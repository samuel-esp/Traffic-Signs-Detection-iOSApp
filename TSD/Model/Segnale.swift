//
//  Segnale.swift
//  TSD
//
//  Created by Samuel Esposito on /1612/20.
//

import Foundation

class Segnale: Codable{
    
    let id: String
    let title: String
    let imagename: String
    
    init(id: String, imagename: String, title: String){
        self.id = id
        self.title = title
        self.imagename = imagename
    }
    
}
