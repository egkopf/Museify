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
import CoreLocation

struct HuntStops: View {
    @State var stops = [Stop]()
    @State var images = [String: UIImage]()
    @State var name: String
    var db = Firestore.firestore()
    @ObservedObject var locationManager = LocationManager()

    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }

    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double))
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
        NavigationView {
            VStack{
                Text("Stops:").font(.largeTitle)
                if self.images.count > 0 && self.stops.count == images.count {
                    List {
                        ForEach(self.stops, id: \.self) { stop in
                            NavigationLink(destination: CompleteAStop(stop: stop, images: self.images)) {
                                VStack{
                                    HStack {
                                        Text("\(stop.name)")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .frame(width: 300, height: 40)
                                            .background(Color.blue)
                                        Image(uiImage: self.images[stop.imgName]!).resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                    Text("\(CLLocation(latitude: self.userLatitude, longitude: self.userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))) meters away!")
                                        .font(.footnote)
                                }
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
}

struct HuntStops_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
