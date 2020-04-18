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
    @State private var showImagePicker: Bool = false
    @State private var coverImage: UIImage? = nil
    var db = Firestore.firestore()
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
    
    func uploadCoverImage() {

        let storageRef = Storage.storage().reference()
        let storageRefSpecific = storageRef.child("images/\(name)CoverImage")
        //This is a big problem
        let imgData = coverImage?.jpegData(compressionQuality: 100)
        let uploadTask = storageRefSpecific.putData(imgData!, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          storageRefSpecific.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
    }
        
    func addCoverImage() {
        showImagePicker = true
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
                    ZStack {
                        
                        Button("Choose a \nCover Image") {
                            self.showImagePicker = true
                        }.disabled(!self.active)
                            .sheet(isPresented: self.$showImagePicker) {
                                PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$coverImage)
                            }
                        if coverImage != nil {
                            Image(uiImage: coverImage!).resizable().frame(height: 150)
                        }
                        
                    }
                    
                    
                }.padding(10)
                Text("Stops:")
                ScrollView {
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
                                
                            }.onAppear {
                                self.getStops()
                            }
                        }
                    } else {
                        Text("No stops yet!")
                    }
                    
                }.onAppear {print(self.images.count); print(self.stops.count)}
                
                Button(action: self.addHuntAndCreateStop) {
                    Text("Add a Stop (+)")
                }.disabled(!self.active)
                .sheet(isPresented: $variable) {
                    CreateAStop(huntName: "\(self.name)", variable: self.$variable)
                }
                Button(action: self.uploadCoverImage) {
                    Text("Upload Cover Image")
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
