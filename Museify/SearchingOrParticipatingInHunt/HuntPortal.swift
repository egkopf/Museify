//
//  HuntPortal.swift
//  Museify
//
//  Created by Ethan Kopf on 6/20/20.
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

struct HuntPortal: View {
    @State var dist: Double
    @State var stopsCounter = 0
    @State var coverImage: Image?
    @State var name: String
    @State var uiimage: UIImage?
    @State var retrieved = false
    var db = Firestore.firestore()
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var auth: Authentication

    
    func getStops() {
        print("Getting stops for \(name)...")
        let stopRef = db.collection("hunts").document("\(String(describing: name))").collection("stops")
        
        stopRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.stopsCounter = 0
                print("Getting images for \(self.name)...")
                for _ in querySnapshot!.documents {
                    self.stopsCounter += 1
                }
                let imgRef = Storage.storage().reference().child("images/\(self.name)CoverImage")
                imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                    if let theError = error {print(theError); return}
                    self.uiimage = UIImage(data: data!)!
                }
            }
        }
        self.retrieved = true
    }
    

    var body: some View {
        VStack {
            if self.retrieved == false || uiimage == nil {
                Text("Gathering hunt data...").onAppear {
                    self.getStops()
                }
            } else {
                VStack {
                    
                    Image(uiImage: uiimage!).resizable().frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(self.name).font(.custom("Averia-Bold", size: 24))
                    Text("Stops: \(stopsCounter)")
                    Text("Closest stop: \(dist, specifier: "%.2f") miles away")
                    NavigationLink(destination: HuntStops(name: self.name)) {
                        Text("Start \(self.name)").padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                    }
                }
                
            }
        }
        
    }
}

struct HuntPortal_Previews: PreviewProvider {
    static var previews: some View {
        HuntStops(name: "Trees")
    }
}
