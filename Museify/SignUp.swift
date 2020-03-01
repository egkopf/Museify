//
//  SignUp.swift
//  Museify
//
//  Created by Aron Korsunsky on 2/18/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import Combine
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SignUp: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @State var didItWork: Bool = false
    @EnvironmentObject var auth: Authentication
    var db = Firestore.firestore()
    
    func signUp() {
        self.error = ""
        auth.signUp(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
//                self.email = ""
//                self.password = ""
                self.didItWork = true
            }
        }
    }
    
    func addPerson() {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": email
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    
    func SignUpAndAddPerson() {
        signUp()
        if error == "" {addPerson()}
        // Adds the new user to the database if signUo succeeds and does not if signUp fails. There is a bug where if signUp fails and then succeeds, it does not add the user to the database.
    }
    
    var body: some View {
        VStack {
            Text("Sign Up as a New User:")
                .font(.headline)
            
            
            VStack {
                HStack {
                    Text("Email:")
                    TextField("Enter Email", text: $email)
                    
                }
                
                HStack{
                    Text("Password:")
                    TextField("Enter Password", text: $password)
                }
                
            }.frame(width: 350)
            
            
            NavigationLink(destination: ContentView(username: email), isActive: $didItWork) {
                Button(action: self.SignUpAndAddPerson) {
                    Text("Sign up")
                }
            }
            
            if error != "" {
                Text("There was an error creating account.").foregroundColor(.red)
            }
            Spacer()
        }
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
