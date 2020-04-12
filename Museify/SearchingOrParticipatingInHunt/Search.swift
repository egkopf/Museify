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

class Hunt: Identifiable, Equatable, CustomStringConvertible {
    static func == (lhs: Hunt, rhs: Hunt) -> Bool {
        return lhs.name == lhs.name && lhs.description == lhs.description
    }
    
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
    @State public var searchBar = "A"
    
    func getAllHunts() {
        db.collection("hunts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let newHunt = Hunt(name: document.data()["name"] as! String, description: document.data()["description"] as! String)
                    for hunt in self.hunts {if hunt.name == newHunt.name {return}}
                    self.hunts.append(Hunt(name: document.data()["name"] as! String, description: document.data()["description"] as! String))
                }
            }
        }
        self.hunts.filter{$0.name.contains("\(self.$searchBar)")}

    }
    
    func getAllHuntsAndClear() {
        self.hunts = [Hunt]()
        self.getAllHunts()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("💙Hunts💙").font(.largeTitle)
                HStack {
                    Text("Search:")
                    TextField("Search for Hunt", text: $searchBar, onEditingChanged: { _ in self.getAllHuntsAndClear()})
                }
                List(self.hunts) { hunt in
                    NavigationLink(destination: HuntStops(name: hunt.name)) {
                        HuntRow(name: hunt.name, description: hunt.description)
                    }
                }.onAppear {
                    self.getAllHunts()
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
