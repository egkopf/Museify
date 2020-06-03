//
//  LogIn.swift
//  Museify
//
//  Created by Aron Korsunsky on 2/18/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine
import SwiftUI

struct LogIn: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @State var didItWork: Bool = false
    @EnvironmentObject var auth: Authentication
    
    func signIn() {
        self.error = ""
        auth.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
//                self.email = ""
//                self.password = ""
                self.didItWork = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Sign in as an existing user:")
                .font(.headline)
            
            VStack {
                HStack {
                    Text("Email:")
                    TextField("Enter email", text: $email)
                }
                
                HStack{
                    Text("Password:")
                    TextField("Enter password", text: $password)
                }
            }.frame(width: 350)
            
            
            
            NavigationLink(destination: ContentView(username: email), isActive: $didItWork) {
                Button(action: self.signIn) {
                    Text("Sign in")
                }
            }
            
            if error != "" {
                Text("There was an error logging in.").foregroundColor(.red)
            }
            Spacer()
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
    }
}
