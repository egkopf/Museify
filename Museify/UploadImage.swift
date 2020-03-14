//
//  UploadImage.swift
//  Museify
//
//  Created by Ethan Kopf on 3/14/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

struct UploadImage: View {
    func uploadImage(filepath: String, filename: String) {
        //Filename does include extension
        let storageRef = Storage.storage().reference()
        let logoImagesRef = storageRef.child("images/\(filename)")
        
        let localFile = URL(string: "file://\(filepath)")!
        print("Uploading \(filename) to  images")

        let uploadTask = logoImagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                print("metadata error")
                return
            }

            //let size = metadata.size
            
            logoImagesRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("url error; url: \(url)")
                    return
                }
            }
        }
    }
    
    var body: some View {
        //put in some text boxes for filepath and filename
        //something is wrong... whatever
        Button(action: self.uploadImage(filepath: "sdfgsdf", filename: "sdfgsdfg")) {
            Text("Upload Image")
        }
        
    }
}

struct UploadImage_Previews: PreviewProvider {
    static var previews: some View {
        UploadImage()
    }
}
