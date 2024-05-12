//
//  LoginView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 03/03/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject{
    
    func signInGoogle() async throws{
    
        guard let topVC = Utilities.shared.topViewController()
         
        else{
            throw URLError(.cannotFindHost)
        }
        let gidsigninresult = GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidsigninresult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        let accessToken = gidsigninresult.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    }
}


struct LoginView: View {
    @State private var Email = ""
    @State private var Password = ""
    @EnvironmentObject var viewmodel: AuthViewModel
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack{
            VStack{
                //image
                Image("Forge_logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height:120)
                    .padding(.vertical, 32)
                    .cornerRadius(10)
                
                //form contents
                VStack(spacing: 30){
                    InputView(text:$Email,
                              title:"Email Address",
                              placeholder:"name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    InputView(text:$Password,
                              title: "Password",
                              placeholder: "enter password",
                              issecurefield: true)
                }
                
                .padding(.horizontal)
                .padding(.top, 45)
                
                //signin button
                Button{
                    Task{
                        try await viewmodel.signin(withemail: Email, password: Password)
                    }
                }
            label: {
                HStack{
                    Text("Sign in")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .disabled(!formisvalid)
            .opacity(formisvalid ? 1.0 : 0.5)
            .padding(.top, 24)
                Spacer()
                
                
                
                
                //google sign in
//                                Button("google signin")
//                                {
//                                    Task{
//                                        viewmodel.signinwithgoogle()
//                                    }
//                                }
                 
//                NavigationLink{
//                    RegistrationView()
//                        .environmentObject(viewmodel)
//                        .navigationBarBackButtonHidden(true)
//                }
//            label:{
//                HStack(spacing: 1){
//                    Text("Google Signin ")
//                }
//                .onTapGesture {
//                        // Initiating Google Sign-In process
//                        GIDSignIn.sharedInstance()?.signIn()
//            }
                
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                    
                }
                
                    Spacer()
                
                //signup button
                NavigationLink{
                    RegistrationView()
                        .environmentObject(viewmodel)
                        .navigationBarBackButtonHidden(true)
                    
                }
            label: {
                HStack(spacing: 3){
                    Text("Dont have an account?")
                    Text("Sign Up!")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .font(.system(size: 15))
            }
                
                
                
                
                
            }
        }
    }
}
    extension LoginView: AuthenticationFormProtocol{
        var formisvalid: Bool{
            return !Email.isEmpty
            && Email.contains("@")
            && !Password.isEmpty
            && Password.count > 6
        }
    }


struct LoginView_preview: PreviewProvider{
    static var previews: some View{
        LoginView()
    }
}
