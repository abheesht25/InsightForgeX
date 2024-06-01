//
//  PlusView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 15/03/24.
//

import Foundation
import SwiftUI
import UIKit
final class Application_Utility{
    static var RootViewController: UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        return root
    }
    
    
    
}
