//
//  ContentView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 03/03/24.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewmodel: AuthViewModel
    var body: some View{
        if viewmodel.userSession != nil {
            ProfileView()
                .environmentObject(viewmodel)
        } else {
            LoginView()
                .environmentObject(viewmodel)
        }
    }
}

struct contentview_Preview: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
