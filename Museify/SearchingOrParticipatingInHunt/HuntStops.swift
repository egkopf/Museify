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
    @State private var showActionSheet = false
    @State var showImagePicker = false
    @State var uiimage: UIImage?
    @State var sourceType: Int = 0
    @State var photoLatitude: Double = 0.0
    @State var photoLongitude: Double = 0.0
    @State var photoDirection: Double = 0.0
    @State var showingGoodAlert = false
    @State var showingWrongAlert = false
    //@State var showDescription = false
    @State var completedStops = [String]()
    var db = Firestore.firestore()
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
    var direction: Double {
        return Double(locationManager.direction ?? 0.0)
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double, Direction: document.data()["direction"] as! Double))
                    print(self.stops)
                    print("images: \(self.images)")
                    
                    
                    imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                        if let theError = error {print(theError); return}
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
    
    func metersToMiles(meters: Double) -> Double {
        return Double(meters / 16.0934).rounded() / 100
    }
    
    func changeActionSheet() {
        self.showActionSheet.toggle()
    }
    
    func getPhotoCoordinatesAndDirection() {
        self.photoLatitude = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.photoLongitude = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
        self.photoDirection = Double(locationManager.direction ?? 0.0)
        print("\(photoLatitude), \(photoLongitude)")
    }
    
    func isMyPhotoRight(photoLat: Double, photoLon: Double, photoDir: Double, stopLat: Double, stopLon: Double, stopDir: Double, stopNam: String) {
        if abs(photoLat - stopLat) < 15.0 && abs(photoLon - stopLon) < 15.0 && abs(photoDir - stopDir) < 25.0 {
            self.completedStops.append(stopNam)
            self.showingGoodAlert = true
        } else {
            self.showingWrongAlert = true
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Stops:")
                if self.images.count > 0 && self.stops.count == images.count {
                    List {
                        ForEach(self.stops, id: \.self) { stop in
                            //NavigationLink(destination: CompleteAStop(stop: stop, images: self.images)) {
                            HStack {
                                VStack {
                                    Image(uiImage: self.images[stop.imgName]!).resizable()
                                        .frame(width: 120, height: 150)
                                    if self.completedStops.contains(stop.name) {
                                        Text("Stop completed :)").font(.custom("Averia-Regular", size: 10)).foregroundColor(.green)
                                    }
                                }
                                VStack {
                                    Text("\(stop.name)").font(.custom("Averia-Regular", size: 32)).foregroundColor(.blue)
                                    if self.completedStops.contains(stop.name) {
                                        Text("\(stop.stopDescription)").font(.custom("Averia-Regular", size: 18)).foregroundColor(.green)
                                    }
                                    HStack {
                                        ArrowView().rotationEffect(.degrees(stop.direction - self.direction))
                                        Text("\(self.metersToMiles(meters: CLLocation(latitude: self.userLatitude, longitude: self.userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))), specifier: "%.2f") miles away!")
                                            .font(.custom("Averia-Regular", size: 18))
                                    }
                                    if self.metersToMiles(meters: CLLocation(latitude: self.userLatitude, longitude: self.userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))) < 0.15 {
                                        Button(action: self.changeActionSheet) {
                                            ZStack {
                                                Rectangle()
                                                    .frame(width: 200, height: 24)
                                                    .foregroundColor(.gray)
                                                    .opacity(0.3)
                                                    //.border(.black, width: 1)
                                                Text("Open Camera!").font(.custom("Averia-Regular", size: 18))
                                            }
                                        }
                                        .actionSheet(isPresented: self.$showActionSheet, content: { () -> ActionSheet in
                                                ActionSheet(title: Text("Select Image"), message: Text("Please select an image"), buttons: [
                                                    ActionSheet.Button.default(Text("Camera"), action: {
                                                        self.sourceType = 0
                                                        self.showImagePicker.toggle()
                                                    }),
                                                    ActionSheet.Button.default(Text("Photo Gallery"), action: {
                                                        self.sourceType = 1
                                                        self.showImagePicker.toggle()
                                                    }),
                                                    ActionSheet.Button.cancel()
                                                ])
                                            })
                                            .sheet(isPresented: self.$showImagePicker) {
                                                ImagePicker(isVisible: self.$showImagePicker, uiimage: self.$uiimage, sourceType: self.sourceType)
                                                    .onDisappear(perform: {self.getPhotoCoordinatesAndDirection()})
                                                    .onDisappear(perform: {self.isMyPhotoRight(photoLat: self.photoLatitude, photoLon: self.photoLongitude, photoDir: self.photoDirection, stopLat: stop.latitude, stopLon: stop.longitude, stopDir: stop.direction, stopNam: stop.name)})
                                        }
                                    }
                                }.offset(x: 20)
                                .alert(isPresented: self.$showingGoodAlert) {
                                    Alert(title: Text("Congratualtions!"), message: Text("You have successfully completed the stop and have unlocked its information!"), dismissButton: .default(Text("Got it!")))
                                }
                                .alert(isPresented: self.$showingWrongAlert) {
                                    Alert(title: Text("Not quite!"), message: Text("Make sure that you are in the right location and are facing the right way!"), dismissButton: .default(Text("Okay")))
                                }
                            }
                            //}
                        }
                    }
                } else {
                    Text("No stops yet!")
                }
                Spacer()
            }.onAppear {self.getStops()}
                .offset(y: -60)
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct HuntStops_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
