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
    
    @State var filepath: String = ""
    @State var filename: String = ""
    
    func uploadImage() {
        //Filename does include extension
        let storageRef = Storage.storage().reference()
        let logoImagesRef = storageRef.child("images/\(self.filename)")
        
        let localFile = URL(string: "file://\(self.filepath)")!
        print("Uploading \(self.filename) to  images")

        let _ = logoImagesRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let _ = metadata else {print("metadata error"); return}
            
            logoImagesRef.downloadURL { (url, error) in
                guard let _ = url else {print("url error; url: \(String(describing: url))"); return}
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Filepath:")
                TextField("Enter filepath", text: $filepath)
                
            }.padding(25)
            
            HStack{
                Text("Filename:")
                TextField("Enter filename", text: $filename)
            }.padding(25)
            
            Button(action: self.uploadImage) {
                Text("Upload Image")
            }
        }
    }
}

struct UploadImage_Previews: PreviewProvider {
    static var previews: some View {
        UploadImage()
    }
}
