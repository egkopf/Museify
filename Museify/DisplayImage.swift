//
//  ContentView.swift
//  Museify
//
//  Created by Ethan Kopf on 1/31/20.
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

struct DisplayImage: View {
    
    @State var image = UIImage()
    @State var imgName: String = ""
    
    func getImage() {
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child("images/\(imgName)")


        imgRef.getData(maxSize: 1 * 5000 * 5000) { data, error in
            if let _ = error {return}
            self.image = UIImage(data: data!)!
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Image")
                TextField("enter filename (on firebase)", text: $imgName)
                
            }.padding(25)
            
            Button(action: self.getImage) {
                Text("Click to see image")
            }
            Image(uiImage: image).resizable()
            .frame(height: 200)
        }
        
    }
}
    

struct DisplayImage_Previews: PreviewProvider {
    static var previews: some View {
        DisplayImage()
    }
}
