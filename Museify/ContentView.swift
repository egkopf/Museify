//
//  ContentView.swift
//  Museify
//
//  Created by Ethan Kopf on 1/31/20.
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

struct ContentView: View {
    @State var selectedView = 0
    @State var name: String = ""
    var db = Firestore.firestore()

    var body: some View {
        TabView(selection: $selectedView) {
            Rectangle()
                .tabItem {
                    Text("Search")
                        .font(.headline)
            }.tag(0)
            Logo()
                .tabItem {
                    Text("Create")
                        .font(.headline)
            }.tag(1)
            Rectangle()
                .tabItem {
                    Text("Hunt Key")
                        .font(.headline)
            }.tag(2)
            Circle()
                .tabItem {
                    Text("Activity")
                        .font(.headline)
            }.tag(3)
            
            VStack {
                TextField("Enter name", text: $name)
                Button(action: addPerson) {
                    Text("Add person")
                }
            }
                .tabItem {
                    Text("Profile")
                        .font(.headline)
            }.tag(4)
        }
    }
    
    
    func addPerson() {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": name
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
