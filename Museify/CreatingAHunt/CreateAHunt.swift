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
    
    
    var active: Bool {return !(self.name == "" || self.description == "" || self.coverImage == nil)}
    
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
//            let size = metadata.size
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double, Direction: document.data()["direction"] as! Double, distanceAway: 0.0))
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
                    Spacer().navigationBarTitle("").navigationBarHidden(true).frame(height: 40)
                    HStack {
                        Logo().frame(width: 80)
                        Spacer().frame(width: 100)
                        VStack {
                            ZStack {
                                Text("Create").font(.custom("Averia-Bold", size: 36)).offset(x: 2, y: 2).foregroundColor(.blue).opacity(0.22)
                                Text("Create").font(.custom("Averia-Bold", size: 36))
                            }
                            if self.name != "" && self.description != "" && self.coverImage != nil {
                                Text("Now, give your hunt some stops!").font(.custom("Averia-Bold", size: 12))
                            } else {
                                Text("First, complete the blue box!").font(.custom("Averia-Bold", size: 12))
                            }
                        }
                    }.padding().frame(width: 400, alignment: .leading)
                    
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
                        VStack {
                            if coverImage == nil {
                                Text("Add a cover image:")
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
                                Image(uiImage: coverImage!).resizable().frame(width: 75, height: 75)
                            }
                        }
                        
                    }.padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                    Text("Stops:")
                    Button(action: self.getStops) {
                        Text("Get Stops")
                    }.disabled(!self.active)
                    Spacer()
                    if images.count > 0 && stops.count == images.count {
                        ScrollView {
                            ForEach(stops, id: \.self) { stop in
                                VStack{
                                    HStack {
                                        Text("\(stop.name)").font(.custom("Averia-Regular", size: 22))
                                            .foregroundColor(.white)
                                            .frame(width: 300, height: 40)
                                            .background(Color.blue).clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        Image(uiImage: self.images[stop.imgName]!).resizable()
                                            .frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                
                            }
                            }.padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.gray).opacity(0.12), alignment: .bottom)
                    } else {
                        Text("No stops yet!")
                    }
                    
                    Button(action: self.addHuntAndCreateStop) {
                        
                        Text("Add a Stop (+)").font(.custom("Averia-Bold", size: 24))
                    }.disabled(!self.active)
                        .sheet(isPresented: $variable) {
                            CreateAStop(huntName: "\(self.name)", variable: self.$variable)
                    }
                    
                    HStack{
                        VStack {
                            Toggle("", isOn: $isItPublic).frame(width: 140).toggleStyle(ColoredToggleStyle(label: "Public", onColor: .blue, offColor: .gray)).saturation(self.active ? 1.0 : 0.2).disabled(!self.active)
                            
                            
                            if !self.isItPublic {
                                VStack {
                                    Text("Hunt code:").onAppear {
                                        self.setID()
                                    }
                                    if self.huntID != nil {
                                        Text("\(huntID!.description)")
                                    }
                                }.padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.gray).opacity(0.12), alignment: .bottom)
                                
                            }
                        }
                        
                        Spacer()
                        Button(action: self.addHunt) {
                            Text("Publish Hunt")
                        }.disabled(!self.active).padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.green).opacity(0.12), alignment: .bottom)
                        
                        
                    }.padding()
                }.frame(width: 400)
            }
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct CreateAHunt_Previews: PreviewProvider {
    static var previews: some View {
        CreateAHunt()
    }
}
