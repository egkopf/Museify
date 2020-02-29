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
            Logo().frame(width: 300, height: 300)
            Text("Sign in as an existing user:")
                .font(.headline)
            
            HStack {
                Text("Email:")
                TextField("Enter email", text: $email)//, onCommit: {self.updateColony()})
            }
            
            HStack{
                Text("Password:")
                TextField("Enter password", text: $password)//, onCommit: {self.updateColony()})
            }
            
            NavigationLink(destination: ContentView(username: email), isActive: $didItWork) {
                Button(action: self.signIn) {
                    Text("Sign in")
                }
            }
            
            if error != "" {
                Text("There was an error logging in.").foregroundColor(.red)
            }
        }
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
    }
}
