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


struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}


class Hunt: Identifiable, Equatable, CustomStringConvertible, Hashable {
    static func == (lhs: Hunt, rhs: Hunt) -> Bool {
        return lhs.name == lhs.name && lhs.description == lhs.description
    }
    
    var name: String
    var description: String
    var key: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    init(name: String, description: String, key: Int?) {
        self.name = name
        self.description = description
        self.key = key
    }
}

struct Search: View {
    var db = Firestore.firestore()
    @State public var hunts = [Hunt]()
    @State public var searchBar = ""
    @State var privKey: String = ""
    @State var currentHuntName = ""
    @State var ready: Bool = false
    
    func getAllHunts() {
        db.collection("hunts").getDocuments() { (querySnapshot, err) in
            if let err = err {print("Error getting documents: \(err)")} else {
                for document in querySnapshot!.documents {
                    let newHunt = Hunt(name: document.data()["name"] as! String, description: document.data()["description"] as! String, key: (document.data()["huntID"] as? Int))
                    for hunt in self.hunts {if hunt.name == newHunt.name {return}}
                    self.hunts.append(newHunt)
                }
            }
        }
    }
    
    func doNothing() {}
    
    func getPrivHunt() {
        for hunt in self.hunts {
            if hunt.key == Int(privKey) {
                self.currentHuntName = hunt.name
                ready = true
            }
        }
        print("no hunt")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchBar, placeholder: "Search")
                List {
                    ForEach(self.hunts) { hunt in
                        if (hunt.name.lowercased().contains(self.searchBar.lowercased()) || hunt.description.lowercased().contains(self.searchBar.lowercased()) || self.searchBar == "") && (hunt.key == nil) {
                            NavigationLink(destination: HuntStops(name: hunt.name)) {
                                HuntRow(name: hunt.name, description: hunt.description)
                            }
                        }
                    }
                }.onAppear {
                    self.getAllHunts()
                }.navigationBarTitle(Text("Hunts"))
                
                VStack {
                    HStack {
                        Text("Enter a Private Hunt Key:")
                            TextField("enter", text: $privKey)
                            Button(action: self.getPrivHunt) {
                               Text("Find")
                            }
                        VStack {
                            Text(currentHuntName)
                            NavigationLink(destination: HuntStops(name: currentHuntName)) {
                                Text("embark")
                            }.padding()
                        }
                        
                        
                        
                    }.padding()
                }.overlay(Rectangle().foregroundColor(.blue).opacity(0.12))
            }
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
