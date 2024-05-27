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
import AuthenticationServices

struct GoogleSignInResultModel{
    let idToken : String
    let accessToken : String
}

@MainActor
final class AuthenticationViewModel: ObservableObject{
    
    func signInGoogle() async throws{
        
        let topVC = await MainActor.run { Utilities.shared.topViewController() }
        
        guard let topVC = topVC else {
            throw URLError(.cannotFindHost)
        }
        let gidsigninresult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidsigninresult.user.idToken?.tokenString else{
            throw URLError(.badServerResponse)
        }
        let accessToken = gidsigninresult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        //try await AuthViewModel.shared.signinwithgoogle(String)
        
    }
}


struct LoginView: View {
    @State private var Email = ""
    @State private var Password = ""
    @EnvironmentObject var viewmodel: AuthViewModel
    @StateObject private var viewModel = AuthenticationViewModel()
    //for apple login
    @StateObject var logindata = AuthViewModel()
    
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
                
                
                
                SignInWithAppleButton{ (request) in
                    
                    //requesting parameters from apple login..
                    //logindata.nonce = randomNonceString(length: 30)
                    request.requestedScopes = [.email,.fullName]
                    //request.nonce = sha256(logindata.nonce)
                } onCompletion: { (result) in
                    
                    //getting error or success...
                    
                    switch result {
                    case .success(let user):
                        print("Success !!")
                        //do login with Forebase
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 55)
                .clipShape(Capsule())
                .padding(.horizontal,100)
                .offset(y: 70)
                
                
                
                
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
