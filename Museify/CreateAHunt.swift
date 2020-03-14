//
//  CreateAHunt.swift
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

struct CreateAHunt: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isItPublic: Bool = true
    @State private var variable: Bool = false
    var db = Firestore.firestore()
    
    func addHunt() {
        db.collection("hunts").document("\(name)").setData([
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
    
    func addHuntAndCreateStop() {
        addHunt()
        variable = true
    }
    
    func addCoverImage() {
        print("add cover image")
    }
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    VStack {
                        HStack{
                            Text("Name:")
                            TextField("Enter Name", text: $name)
                        }
                        HStack{
                            Text("Description:")
                            TextField("Enter Description", text: $description)
                        }
                    }
                    Button(action: self.addCoverImage) {
                        Text("Add a cover image\n(+)").multilineTextAlignment(.center)
                    }
                    
                }.padding(10)
                Text("Stops:")
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<10) {
                            Text("Stop \($0)")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .frame(width: 300, height: 40)
                                .background(Color.blue)
                        }
                    }
                }
                NavigationLink(destination: CreateAStop(huntName: "\(name)"), isActive: $variable) {
                    Button(action: self.addHuntAndCreateStop) {
                        Text("Add a Stop (+)")
                    }
                }
                HStack{
                    Toggle(isOn: $isItPublic) {
                        Text("Public")
                    }.frame(width: 140)
                    Spacer()
                    Button(action: self.addHunt) {
                        Text("Publish Hunt")
                    }
                }.padding(10)
            }
        }
    }
}

struct CreateAHunt_Previews: PreviewProvider {
    static var previews: some View {
        CreateAHunt()
    }
}
