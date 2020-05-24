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
    @State var images = [String: UIImage]()
    

    
    func getAllHunts() {
        db.collection("hunts").getDocuments() { (querySnapshot, err) in
            if let err = err {print("Error getting documents: \(err)")} else {
                for document in querySnapshot!.documents {
                    let newHunt = Hunt(name: document.data()["name"] as! String, description: document.data()["description"] as! String, key: (document.data()["huntID"] as? Int))
                    for hunt in self.hunts {if hunt.name == newHunt.name {return}}
                    self.hunts.append(newHunt)
                    if querySnapshot!.documents.count == self.hunts.count {self.getAllImages()}
                }
            }
        }
        print("hunts: \(hunts)")
    }
    
    func getAllImages() {
        let tempHunts = hunts.filter({$0.key == nil})
        if tempHunts.count == images.count {return}
        
        for hunt in hunts {
            if hunt.key == nil {
                let storageRef = Storage.storage().reference()
                let imgRef = storageRef.child("images/\(hunt.name)CoverImage")
                
                imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                    if let theError = error {print(theError); return}
                    print("no error")
                    self.images[hunt.name] = UIImage(data: data!)!
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
                Spacer().navigationBarTitle("").navigationBarHidden(true).frame(height: 40)
                HStack {
                    Logo().frame(width: 80)
                    Spacer().frame(width: 100)
                    ZStack {
                        Text("Hunts").font(.custom("Averia-Bold", size: 36)).offset(x: 2, y: 2).foregroundColor(.blue).opacity(0.22)
                        Text("Hunts").font(.custom("Averia-Bold", size: 36))
                    }
                }.padding().frame(width: 400, alignment: .leading)
                
                
                SearchBar(text: $searchBar, placeholder: "Search")
                List {
                    ForEach(self.hunts) { hunt in
                        if (hunt.name.lowercased().contains(self.searchBar.lowercased()) || hunt.description.lowercased().contains(self.searchBar.lowercased()) || self.searchBar == "") && (hunt.key == nil) {
                            NavigationLink(destination: HuntStops(name: hunt.name)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(hunt.name)").font(.custom("Averia-Bold", size: 18))
                                        Text("\(hunt.description)")
                                
                                    }.font(.custom("Averia-Regular", size: 18))
                                    Spacer()
                                    if self.images[hunt.name] != nil {
                                        Image(uiImage: self.images[hunt.name]!).resizable()
                                            .frame(width: 50, height: 50, alignment: .trailing).clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    }.onAppear {
                    self.getAllHunts()
                    }
                
                VStack {
                    HStack {
                        Text("Enter a Private Hunt Key:")
                        TextField("enter", text: $privKey).frame(width: 60)
                        Button(action: self.getPrivHunt) {
                            Text("find")
                        }
                        VStack {
                            if currentHuntName != "" {
                                Text(currentHuntName)
                            }
                            
                            NavigationLink(destination: HuntStops(name: currentHuntName)) {
                                Text("embark")
                            }.disabled(currentHuntName == "")
                        }
                        
                        
                        
                    }.padding()
                }.background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                Spacer().frame(height: 20)
            }.frame(width: 400)
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search()
    }
}
