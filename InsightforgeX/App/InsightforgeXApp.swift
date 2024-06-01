//
//  InsightforgeXApp.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 03/03/24.
//

import SwiftUI
import Firebase
import GoogleSignIn


@main
    struct InsightforgeXApp: App {
    @StateObject var viewmodel = AuthViewModel()
    let persistenceController = PersistenceController.shared
    init(){
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewmodel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDeligate: NSObject, UIApplicationDelegate{
//    func applicationWillTerminate(_ application: UIApplication, didFinishLaunchingWithOptions launchoptions:[UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        <#code#>
//    }
    @available(iOS 9.0,*)
    func applicationWillTerminate(_ application: UIApplication, open url:URL, options:[UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
