//
//  RegistrationView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 03/03/24.
//

import SwiftUI
import GoogleSignIn

struct RegistrationView: View {
    @State private var Email = ""
    @State private var fullname = ""
    @State private var Password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewmodel: AuthViewModel
    @State var flag = true
    
    var body: some View {
        VStack {
            if flag {
                Image("Forge_logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height:120)
                    .padding(.vertical, 32)
                    .cornerRadius(10)
                
                VStack(spacing: 10){
                    InputView(text:$Email,
                              title:"Email Address",
                              placeholder:"name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text:$fullname,
                              title:"Full Name",
                              placeholder:"Enter your full Name")
                    
                    InputView(text:$Password,
                              title: "Password",
                              placeholder: "enter password",
                              issecurefield: true)
                    
                    ZStack(alignment: .trailing){
                        InputView(text:$confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Re enter your password",
                                  issecurefield: true)
                        if !Password.isEmpty && !confirmPassword.isEmpty{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        }else{
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 45)
                
                Button {
                    Task{
                        print("RC::: started")
                        try await viewmodel.createuser(withemail:Email,
                                                                password:Password,
                                                                fullname :fullname)
                        flag = false
                        print("RC::: viewModle.currentUser: \(viewmodel.currentUser)")
                        print("RC::: done")
                        
                    }
                }
            label: {
                HStack{
                    Text("Sign up")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formisvalid)
            .opacity(formisvalid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
                
                Spacer()
                
                Button{
                    dismiss()
                }
                
                
                
            label: {
                HStack(spacing: 3){
                    Text("Already have an account?")
                    Text("Sign In!")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .font(.system(size: 14))
            }
            } else {
                ProfileView()
                    .environmentObject(viewmodel)
                //MyLoggedInView()
            }
            
            
        }
    }
}
extension RegistrationView: AuthenticationFormProtocol{
    var formisvalid: Bool{
        return !Email.isEmpty
        && Email.contains("@")
        && !Password.isEmpty
        && Password.count > 6
        && confirmPassword == Password
        && !fullname.isEmpty
    }
}

    
    struct RegistrationView_Preview: PreviewProvider{
        static var previews: some View{
            RegistrationView()
        }
    }

