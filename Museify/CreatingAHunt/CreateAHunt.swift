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
import CoreLocation

struct CreateAHunt: View {
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isItPublic: Bool = true
    @State private var variable: Bool = false
    @State private var coverImage: UIImage?
    @State private var huntID: Int? = nil
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var sourceType: Int = 0
    var db = Firestore.firestore()
    @State var stops = [Stop]()
    @State var images = [String: UIImage]()
    
    
    var active: Bool {return !(self.name == "" || self.description == "")}
    
    func setID() {
        huntID = Int.random(in: 100000...999999)
    }
    
    func addHunt() {
        if self.huntID == nil {
            db.collection("hunts").document("\(name)").setData(["name": "\(name)", "description": "\(description)"]) { err in
                if let err = err {print("Error writing document: \(err)")}
                else {print("Document successfully written!")}
            }
        } else {
            db.collection("hunts").document("\(name)").setData(["name": "\(name)", "description": "\(description)", "huntID": huntID!]) { err in
                if let err = err {print("Error writing document: \(err)")}
                else {print("Document successfully written!")}
            }
        }
        
    }
    
    func uploadCoverImage() {
        
        let storageRef = Storage.storage().reference()
        let storageRefSpecific = storageRef.child("images/\(name)CoverImage")
        
        let imgData = coverImage?.jpegData(compressionQuality: 100)
        let uploadTask = storageRefSpecific.putData(imgData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {return}
            
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRefSpecific.downloadURL { (url, error) in
                guard let downloadURL = url else {return}
            }
        }
    }
    
    func addHuntAndCreateStop() {
        addHunt()
        uploadCoverImage()
        variable = true
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double, Direction: document.data()["direction"] as! Double))
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
        NavigationView {
            ZStack {
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
                        
                        CameraButtonView(showActionSheet: $showActionSheet)
                            .actionSheet(isPresented: $showActionSheet, content: { () -> ActionSheet in
                                ActionSheet(title: Text("Select Image"), message: Text("Please select an image"), buttons: [
                                    ActionSheet.Button.default(Text("Camera"), action: {
                                        self.sourceType = 0
                                        self.showImagePicker.toggle()
                                    }),
                                    ActionSheet.Button.default(Text("Photo Gallery"), action: {
                                        self.sourceType = 1
                                        self.showImagePicker.toggle()
                                    }),
                                    ActionSheet.Button.cancel()
                                ])
                            })
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(isVisible: self.$showImagePicker, uiimage: self.$coverImage, sourceType: self.sourceType)
                        }
                        if coverImage != nil {
                            Image(uiImage: coverImage!).resizable().frame(height: 150)
                        }
                        
                        
                    }.padding(10)
                    Text("Stops:")
                    Button(action: self.getStops) {
                        Text("Get Stops")
                    }
                    Spacer()
                    if images.count > 0 && stops.count == images.count {
                        VStack(spacing: 10) {
                            ForEach(stops, id: \.self) { stop in
                                VStack{
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
                        }
                    } else {
                        Text("No stops yet!")
                    }
                    
                    Button(action: self.addHuntAndCreateStop) {
                        
                        Text("Add a Stop (+)")
                    }.disabled(!self.active)
                        .sheet(isPresented: $variable) {
                            CreateAStop(huntName: "\(self.name)", variable: self.$variable)
                    }
                    
                    HStack{
                        VStack {
                            Toggle(isOn: $isItPublic) {
                                Text("Public")
                            }.frame(width: 140)
                            
                            if !self.isItPublic {
                                Text("Hunt code:").onAppear {
                                    self.setID()
                                }
                                if self.huntID != nil {
                                    Text("\(huntID!.description)")
                                }
                            }
                        }
                        
                        Spacer()
                        Button(action: self.addHunt) {
                            Text("Publish Hunt")
                        }.disabled(!self.active)
                        
                        
                    }.padding(10)
                }
            }
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct CreateAHunt_Previews: PreviewProvider {
    static var previews: some View {
        CreateAHunt()
    }
}
