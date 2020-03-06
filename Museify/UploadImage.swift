//
//  UploadImage.swift
//  Museify
//
//  Created by Aron Korsunsky on 3/5/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI
import Firebase

struct UploadImage: View {
    func uploadImage() {
        let storageRef = Storage.storage().reference()
        let localFile = URL(string: "file://desktop/M.jpg")!

        // Create a reference to the file you want to upload
        let logoRef = storageRef.child("images/logos.jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = logoRef.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
        }
    }
    var body: some View {
        Button(action: self.uploadImage) {
            Text("Upload Image")
        }
    }
}

struct UploadImage_Previews: PreviewProvider {
    static var previews: some View {
        UploadImage()
    }
}
