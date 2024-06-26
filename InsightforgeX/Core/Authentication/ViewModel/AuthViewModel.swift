//
//  AuthViewModel.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 06/03/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit

protocol AuthenticationFormProtocol{
    var formisvalid: Bool {get}
    
}
@MainActor
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var nonce = ""
    
    
    //for OIDC
    var provider = OAuthProvider(providerID: "oidc.insightforgex")
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchuser()
        }
    }
    
    
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handle =  GIDSignIn.sharedInstance.handle(url)
        if handle{
            print("handle hai ---->")
            print(handle)
            return true
        }
        else{
            return false
        }
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return  String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    func signinwithgoogle(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_Utility.RootViewController){  user, error in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard
                let user = user?.user,
                let idtoken = user.idToken else {return}
            let accesstoken = user.accessToken
            
            let credentials = GoogleAuthProvider.credential(withIDToken: idtoken.tokenString, accessToken: accesstoken.tokenString)
            
            Auth.auth().signIn(with: credentials){ res, error in
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let user = res?.user else {return}
                print (user)
                //----------------
                let db = Firestore.firestore()
                db.collection("user").document(String((res?.user.uid)!)).setData([
                    "id" : String((res?.user.uid)!),
                    "displayName" : (res?.user.displayName)!,
                    "knownLanguageCodes" : []
                ], merge: true)
                
                
                //----------------
            }
            
        }
    }
    
    
    
    
    func tokenSignInExample(idToken: String) {
        guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else {
            return
        }
        let url = URL(string: "https://yourbackend.example.com/tokensignin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: authData) { data, response, error in
            // Handle response from your backend.
        }
        task.resume()
    }
    
    func signout(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch{
            print("DEBUG: failed to signout with error \(error.localizedDescription)")
        }
    }
    
    func deleteacc() async{
        do {
            guard let user = Auth.auth().currentUser else {
                print("DEBUG: No user is currently signed in.")
                return
            }
            
            try await user.delete()
            print("DEBUG: User deleted successfully.")
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to delete user with error \(error.localizedDescription)")
        }
    }
    
    func fetchuser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        do {
            let documentSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            print("RC::: documentSnapshot: \(documentSnapshot)")
            DispatchQueue.main.async {
                do {
                    self.currentUser = try documentSnapshot.data(as: User.self)
                } catch {
                    print("DEBUG: Failed to parse user data with error \(error.localizedDescription)")
                }
            }
        } catch {
            print("DEBUG: Failed to fetch user document with error \(error.localizedDescription)")
        }
    }
}

//MARK: Sign in with email function
extension AuthViewModel {
    
    func signin(withemail email:String, password:String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchuser()
        }
        catch{
            print("DEBUG: failed to log with the error \(error.localizedDescription)")
        }
    }
    
    func createuser(withemail email: String, password: String, fullname: String) async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchuser()
            
        }
        catch{
            print("DEBUG: failed to create user with error \(error.localizedDescription)")
        }
    }
    
    
}
//MARK: Sign in with SSO Function
extension AuthViewModel {
    
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else { return }
            Task {
                do {
                    try await signInWithApple(credential: credential)
                } catch {
                    print("Error signing in with Apple: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            print("Apple Sign-In failed: \(error.localizedDescription)")
        }
    }
    
    private func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let appleIDToken = credential.identityToken else {
            throw NSError(domain: "SignInWithAppleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "SignInWithAppleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"])
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        let result = try await Auth.auth().signIn(with: firebaseCredential)
        self.userSession = result.user
        await fetchuser()
    }
    
    
    
    
}
