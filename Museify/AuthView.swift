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
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @EnvironmentObject var auth: Authentication
    
    func signIn() {
        auth.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        Text("yo")
    }

}
