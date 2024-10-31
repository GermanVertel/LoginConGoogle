//
//  AuthView.swift
//  LoginConGoogle
//
//  Created by German David Vertel Narvaez on 31/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthViewModel: ObservableObject {
    
    @Published var loginState = false

    // Función para iniciar sesión
    func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: No se encontró el clientID")
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Error: No se pudo obtener rootViewController")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al iniciar sesión:", error.localizedDescription)
                return
            }

            // Accedemos a idToken y accessToken de manera segura, ya que no son opcionales en este contexto.
            if let user = result?.user {
                let idToken = user.idToken?.tokenString ?? ""
                let accessToken = user.accessToken.tokenString
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { _, error in
                    if let error = error {
                        print("Error al iniciar sesión:", error.localizedDescription)
                    } else {
                        self.loginState = true
                    }
                }
            } else {
                print("Error: No se pudo obtener el usuario de Google")
            }
        }
    }
    

    
    
    // Función para cerrar sesión
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            loginState = false
        } catch {
            print(error.localizedDescription)
        }
    }
}
