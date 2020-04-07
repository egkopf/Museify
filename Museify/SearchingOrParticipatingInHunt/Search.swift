//
//  Search.swift
//  Museify
//
//  Created by Aron Korsunsky on 4/2/20.
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
import FirebaseStorage

class Hunt: Identifiable {
    var name: String
    var description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}

struct Search: View {
    var db = Firestore.firestore()
    @State public var hunts = [Hunt]()
    
    func getAllHunts() {
        db.collection("hunts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.hunts.append(Hunt(name: document.data()["name"] as! String, description: document.data()["description"] as! String))
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: self.getAllHunts) {
                    Text("Get hunts")
                }
                
                List(self.hunts) { hunt in
                    NavigationLink(destination: HuntStops(name: hunt.name)) {
                        HuntRow(name: hunt.name, description: hunt.description)
                    }
                }
            }
        }
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
