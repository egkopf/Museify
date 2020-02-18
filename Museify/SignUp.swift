//
//  SignUp.swift
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

struct SignUp: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @State var didItWork: Bool = false
    @EnvironmentObject var auth: Authentication
    
    func signUp() {
        auth.signUp(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.email = ""
                self.password = ""
                self.didItWork = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Sign Up as a New User:")
                .font(.headline)
            HStack {
                Text("Email:")
                TextField("Enter Email", text: $email)//, onCommit: {self.updateColony()})
            }
            HStack{
                Text("Password:")
                TextField("Enter Password", text: $password)//, onCommit: {self.updateColony()})
            }
            Button(action: self.signUp) {
                Text("sign up")
            }
            if didItWork {
                NavigationView {
                    VStack {
                        NavigationLink(destination: ContentView()) {
                            Text("Proceed to App")
                        }
                    }
                }
            }
        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
