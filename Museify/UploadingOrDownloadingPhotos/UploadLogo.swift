////
////  UploadImage.swift
////  Museify
////
////  Created by Aron Korsunsky on 3/5/20.
////  Copyright © 2020 Ethan Kopf. All rights reserved.
////
//
//import SwiftUI
//import Firebase
//import FirebaseStorage
//
//struct UploadLogo: View {
//    func uploadImage() {
//        let storageRef = Storage.storage().reference()
//        let logoImagesRef = storageRef.child("images/logos.jpg")
//        
//        let localFile = URL(string: "file:///Users/ethankopf/Desktop/M.jpg")!
//        print("Uploading \(localFile) to location \(logoImagesRef)")
//
//        let _ = logoImagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
//            guard let _ = metadata else {return}
//
//            //let size = metadata.size
//            
//            logoImagesRef.downloadURL { (url, error) in
//                guard let _ = url else {return}
//            }
//        }
//    }
//    
//    var body: some View {
//        Button(action: self.uploadImage) {
//            Text("Upload Image")
//        }
//    }
//}
//
//struct UploadLogo_Previews: PreviewProvider {
//    static var previews: some View {
//        UploadLogo()
//    }
//}
