//
//  UploadImage.swift
//  Museify
//
//  Created by Aron Korsunsky on 3/5/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct UploadImage: View {
    func uploadImage() {
        let storageRef = Storage.storage().reference()
        let localFile = URL(string: "file://desktop/M.jpg")!

        let logoRef = storageRef.child("images/logos.jpg")

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
