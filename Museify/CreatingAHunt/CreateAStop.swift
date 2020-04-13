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
    @State var filepath: String = ""
    @State var filename: String = ""
    @Binding var variable: Bool
    @ObservedObject var locationManager = LocationManager()

    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }

    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }

    func uploadImage() {
        //Filename does include extension
        let storageRef = Storage.storage().reference()
        let logoImagesRef = storageRef.child("images/\(self.filename)")
        
        let localFile = URL(string: "file://\(self.filepath)")!
        print("Uploading \(self.filename) to  images")
        
        let _ = logoImagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
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
            "imageName": filename,
            "locationStatus": locationManager.statusString,
            "latitude": userLatitude,
            "logitude": userLongitude
        ]) { err in
            if let err = err {print("Error writing document: \(err)")}
            else {print("Document successfully written!")}
        }
        uploadImage()
        self.variable.toggle()
    }
    
    var body: some View {
        VStack{
            Text("New Stop")
            HStack{
                Text("Name:")
                TextField("Enter Name", text: $name)
            }
            
            TextField("Enter a description or clues about the stop", text: $description).frame(width: 250, height: 300)
            Text("IMAGE:")
            HStack {
                Text("Filepath:")
                TextField("Enter filepath", text: $filepath)
                
            }.padding(25)
            
            HStack{
                Text("Filename:")
                TextField("Enter filename", text: $filename)
            }.padding(25)
            
            Button(action: self.addStop) {
                Text("Add to Hunt >")
            }
        }
    }
}

struct CreateAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
