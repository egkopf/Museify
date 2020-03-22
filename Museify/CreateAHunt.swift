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
    @State var coverImage = UIImage()
    @State var stops = [Stop]()
    @State var images = [String: UIImage]()
    var active: Bool {return !(self.name == "" || self.description == "")}
    
    func addHunt() {
        db.collection("hunts").document("\(name)").setData(["name": "\(name)", "description": "\(description)"]) { err in
            if let err = err {print("Error writing document: \(err)")}
            else {print("Document successfully written!")}
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
            if let _ = error {return}
            self.coverImage = UIImage(data: data!)!
        }
    }
    
    func getStops() {
        let stopRef = db.collection("hunts").document("\(String(describing: name))").collection("stops")
            
        stopRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.stops = [Stop]()
                for document in querySnapshot!.documents {
                    
                    let storageRef = Storage.storage().reference()
                    let imgRef = storageRef.child("images/\(document.data()["imageName"] as! String)")


                    
                    
                    print(document.data())
                    self.stops.append(Stop(Name: document.data()["name"] as! String, ImgName: document.data()["imageName"] as! String))
                    print(self.stops)
                    print("images: \(self.images)")
                    
                    
                    imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                        if let _ = error {print("error"); return}
                        print("no error")
                        let imageNm = document.data()["imageName"] as! String
                        print(imageNm)
                        self.images[imageNm] = UIImage(data: data!)!
                        print("images: \(self.images)")
                    }
                    
                    
                }
                print("IMAGES: \(self.images)")
            }
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
                    if coverImage == UIImage() {
                        Button(action: self.addCoverImage) {
                            Text("Add a cover image\n(+)").multilineTextAlignment(.center)
                        }
                    } else {
                        Image(uiImage: coverImage).resizable()
                        .frame(height: 100)
                    }
                    
                }.padding(10)
                Text("Stops:")
                ScrollView {
                    Button(action: self.getStops) {
                        Text("Get stops")
                    }
                    if images.count > 0 && stops.count == images.count {
                        VStack(spacing: 10) {
                            ForEach(stops, id: \.self) { stop in
                                HStack {
                                    Text("\(stop.name)")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .frame(width: 300, height: 40)
                                        .background(Color.blue)
                                    Image(uiImage: self.images[stop.imgName]!).resizable()
                                        .frame(width: 50, height: 50)
                                }
                                
                            }
                        }
                    } else {
                        Text("No stops yet!")
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