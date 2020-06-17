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
        db.collection("users").document("\(email)").setData(["password": password]) { err in
            if let err = err {print("Error writing document: \(err)")}
            else {print("Document successfully written!")}
        }
        db.collection("users").document("\(email)").collection("stopsCompleted")
    }
    
    
    func SignUpAndAddPerson() {
        signUp()
        if error == "" {addPerson()}
        // Adds the new user to the database if signUo succeeds and does not if signUp fails. There is a bug where if signUp fails and then succeeds, it does not add the user to the database.
    }
    
    var body: some View {
        VStack {
            Text("Sign Up as a New User:")
                .font(.custom("Averia-Bold", size: 24))
            
            
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
            
            
            NavigationLink(destination: ContentView(username: email).navigationBarBackButtonHidden(true), isActive: $didItWork) {
                Button(action: self.SignUpAndAddPerson) {
                    Text("Sign up")
                }
            }
            
            if error != "" {
                Text(String(error)).foregroundColor(.red)
            }
            Spacer()
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
