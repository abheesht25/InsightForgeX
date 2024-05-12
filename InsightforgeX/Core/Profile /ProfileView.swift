//
//  ProfileView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 04/03/24.
//

import SwiftUI
import UIKit
import MobileCoreServices

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var searchText = ""
    @State private var selectedURL: URL?
    @State private var showSheet = false
    @State private var importing = false
    @State private var csvContent = ""
    @State private var rows: [[String]] = []
    
    
    var body: some View {
        if let user = viewModel.currentUser {
            List{
                Section{
                    HStack{
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width:72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                    }
                        Text("Dashboard...")
                            .font(.title2)
                            .fontWeight(.semibold)
                    
                    
                }
                Section{
                    ZStack(alignment: .leading) {
                        TextField("Search", text: $searchText)
                            .padding(.leading, 36)
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                }
                .navigationBarTitle("Search")
                
                
//                Section("import CSV File"){
//                    HStack(spacing: 12){
//                        Image(systemName: "square.and.arrow.down")
//                            .foregroundColor(.blue)
//                            .padding(.leading, 5)
//                        
//                        Button("Import") {
//                            importing = true
//                        }
//                        .fileImporter(
//                            isPresented: $importing,
//                            allowedContentTypes: [.plainText]
//                        ) { result in
//                            switch result {
//                            case .success(let file):
//                                do {
//                                    csvContent = try String(contentsOf: file)
//                                    rows = parseCSV(content: csvContent)
//                                    print(csvContent)
//                                } catch{
//                                    print("error in reading file; \(error.localizedDescription)")
//                                }
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                            }
//                        }
//                        .foregroundColor(.black)
//                        .padding(.leading, 5)
//                        .font(.subheadline)
//                    }
//                }
//                func parseCSV(content: String) -> [[String]]{
//                    return content
//                        .trimmingCharacters(in: whitespacesAndNewlines)
//                        .components(separatedBy: "\n")
//                        .map{line in line.components(separatedBy: ",")}
//                    
                }
                
                
                
                
                
                Section("General"){
                    HStack{
                        SettingRowView(imagename: "gear",
                                       title: "Version",
                                       tincolor: Color(.systemGray))
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                }
                
                Section("Account"){
                    Button
                    {
                        viewModel.signout()
                    }
                label: {
                    SettingRowView(imagename: "arrow.left.circle.fill", title: "SignOut", tincolor: .red)
                }
                    
                    Button
                    {
                        print("Delete Account..")
                    }
                label: {
                    SettingRowView(imagename: "xmark.circle.fill", title: "Delete Account", tincolor: .red)
                }
                }
                
            }
        }
    }

    
    struct ProfileView_preview: PreviewProvider{
        static var previews: some View{
            let authViewModel = AuthViewModel()
            
            // Provide AuthViewModel as an environment object
            return ProfileView()
                .environmentObject(authViewModel)
        }
    }
