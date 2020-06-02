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
    @State var docs = [String]()
    
    private func getDocument() {
        db.collection("users").document(auth.currentEmail!).collection("stopsCompleted").getDocuments() { (querySnapshot, err) in
            if let err = err {print("Error getting documents: \(err)")} else {
                self.docs = []
                for document in querySnapshot!.documents {
                    let name = document.data()["name"] as! String
                    self.docs.append(name)
                }
            }
        }

    }
    
    var body: some View {
        VStack {
            Logo().frame(width: 300)
            Spacer().frame(height: 100)
            Text("Profile").font(.custom("Averia-Bold", size: 28))
            Text("Welcome \(username)")
            Text("Completed Stops: \(self.docs.description)")
        }.font(.custom("Averia-Regular", size: 18)).onAppear {
            self.getDocument()
            
        }
    }
}
    

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
