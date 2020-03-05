//
//  ProfilePage.swift
//  Museify
//
//  Created by Ethan Kopf on 2/29/20.
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

struct ProfilePage: View {
    var username: String
    @EnvironmentObject var auth: Authentication
    var db = Firestore.firestore()
    
    private func getDocument() {
        let docRef = db.collection("users").document("\(String(describing: auth.currentUser?.uid))")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.get("username") ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Profile").font(.largeTitle)
            Text("Welcome \(username)")
        }
    }
}
    

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
