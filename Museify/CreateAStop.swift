//
//  CreateAStop.swift
//  Museify
//
//  Created by Aron Korsunsky on 3/13/20.
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

struct CreateAStop: View {
    @State private var name: String = ""
    @State private var description: String = ""
    var huntName: String
    var db = Firestore.firestore()
    
    func addStop() {
        db.collection("hunts").document("\(huntName)").collection("stops").document("\(name)").setData([
            "name": "\(name)",
            "description": "\(description)"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    var body: some View {
        VStack{
            Text("New Stop")
            HStack{
                Text("Name:")
                TextField("Enter Name", text: $name)
            }
            
            TextField("Enter a description or clues about the stop", text: $description).frame(width: 250, height: 300)
            Button(action: self.addStop) {
                Text("Add to Hunt >")
            }
        }
    }
}

struct CreateAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
