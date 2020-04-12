//
//  HuntStops.swift
//  Museify
//
//  Created by Aron Korsunsky on 4/2/20.
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

struct HuntStops: View {
    @State var stops = [Stop]()
    @State var images = [String: UIImage]()
    @State var name: String
    var db = Firestore.firestore()
    
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, ImgName: document.data()["imageName"] as! String))
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
        VStack{
            Text("Stops:").font(.largeTitle)
            if self.images.count > 0 && self.stops.count == images.count {
                VStack(spacing: 10) {
                    ForEach(self.stops, id: \.self) { stop in
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
            } else {
                Text("No stops yet!")
            }
            Spacer()
        }.onAppear {self.getStops()}
    }
}

struct HuntStops_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
