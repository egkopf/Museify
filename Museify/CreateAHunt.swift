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
import FirebaseStorage

struct CreateAHunt: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isItPublic: Bool = true
    @State private var variable: Bool = false
    var db = Firestore.firestore()
    @State var image = UIImage()
    var active: Bool {
        if self.name == "" || self.description == "" {
            return false
        } else {
            return true
        }
    }
    
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
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child("images/M image")


        imgRef.getData(maxSize: 1 * 5000 * 5000) { data, error in
            if let error = error {return}
            self.image = UIImage(data: data!)!
        }
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
                    if image == UIImage() {
                        Button(action: self.addCoverImage) {
                            Text("Add a cover image\n(+)").multilineTextAlignment(.center)
                        }
                    } else {
                        Image(uiImage: image).resizable()
                        .frame(height: 100)
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
                    }.disabled(!self.active)
                }
                
                HStack{
                    Toggle(isOn: $isItPublic) {
                        Text("Public")
                    }.frame(width: 140)
                    Spacer()
                    Button(action: self.addHunt) {
                        Text("Publish Hunt")
                    }.disabled(!self.active)
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
