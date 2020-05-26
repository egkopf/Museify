//
//  CreateAStop.swift
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

struct CreateAStop: View {
    @State private var name: String = ""
    @State private var description: String = ""
    var huntName: String
    var db = Firestore.firestore()
    @Binding var variable: Bool
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var uiimage: UIImage?
    @State var sourceType: Int = 0
    @State var photoLatitude: Double = 0.0
    @State var photoLongitude: Double = 0.0
    @State var photoDirection: Double = 0.0
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    var statusString: String {
        return locationManager.statusString
    }
    var direction: Double {
        return Double(locationManager.direction ?? 0.0)
    }
    
    
    func uploadImage() {
        //Filename does include extension
        //let data = Data()
        let storageRef = Storage.storage().reference()
        let logoImagesRef = storageRef.child("images/\(huntName)\(name)")
        let metadata = StorageMetadata()
        metadata.customMetadata = [
            "latitude": "\(userLatitude)",
            "longitude": "\(userLongitude)",
            "direction": "\(direction)"
        ]
        
        //let localFile = URL(string: "file://\(self.filepath)")!
        print("Uploading \(self.name) to  images")
        
        guard let imageData = self.uiimage!.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let uploadTask = logoImagesRef.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {print("metadata error"); return}
            //let size = metadata.size
            
            logoImagesRef.downloadURL { (url, error) in
                guard let _ = url else {print("url error; url: \(String(describing: url)), error: \(String(describing: error))"); return}
            }
        }
    }
    
    func addStop() {
        db.collection("hunts").document(huntName).collection("stops").document(name).setData([
            "name": name,
            "description": description,
            "imageName": huntName + name,
            "locationStatus": statusString,
            "latitude": photoLatitude,
            "longitude": photoLongitude,
            "direction": photoDirection
        ]) { err in
            if let err = err {print("Error writing document: \(err)")}
            else {print("Document successfully written!")}
        }
        uploadImage()
        self.variable.toggle()
    }
    
    func getPhotoCoordinatesAndDirection() {
        self.photoLatitude = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.photoLongitude = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
        self.photoDirection = Double(locationManager.direction ?? 0.0)
        print("\(photoLatitude), \(photoLongitude)")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("New Stop").font(.custom("Averia-Bold", size: 24)).foregroundColor(Color(0x248585))
                HStack{
                    Text("Name:")
                    TextField("Enter Name", text: $name)
                }.font(.custom("Averia-Regular", size: 18)).padding()
                
                HStack{
                    Text("Description:")
                    TextField("Enter Description", text: $description)
                }.font(.custom("Averia-Regular", size: 18)).padding()
                
                
//                HStack{
//                    Text("Filename:")
//                    TextField("Enter filename", text: $filename)
//                }.padding(25)
                
                CameraButtonView(showActionSheet: $showActionSheet).frame(width: 50)
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
                        ImagePicker(isVisible: self.$showImagePicker, uiimage: self.$uiimage, sourceType: self.sourceType)
                            .onDisappear(perform: {self.getPhotoCoordinatesAndDirection()})
                }
                if self.uiimage != nil {
                    Image(uiImage: uiimage!).resizable().frame(width: 180, height: 180)
                }
                
                Button(action: self.addStop) {
                    Text("Add to Hunt >").font(.custom("Averia-Regular", size: 24)).foregroundColor(Color(0x248585))
                }
            }
        }
    }
}

struct CreateAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
