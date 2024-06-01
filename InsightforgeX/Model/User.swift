//
//  User.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 06/03/24.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    let id:String
    let fullname:String
    let email:String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User{
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "abc", email: "xyz@example.com")
}


