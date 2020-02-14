//
//  AuthView.swift
//  Museify
//
//  Created by Ethan Kopf on 2/10/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine
import SwiftUI

struct SigningInView: View {
    @State var email: String = "ergasf"
    @State var password: String = "45gh45n45g"
    @State var error: String = ""
    @EnvironmentObject var auth: Authentication
    
    func signIn() {
        auth.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    func signUp() {
        auth.signUp(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    var body: some View {
        Button(action: self.signUp) {
            Text("sign up")
        }
    }

}
