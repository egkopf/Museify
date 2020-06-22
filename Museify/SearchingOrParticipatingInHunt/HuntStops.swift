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
    @State var prevLat: Double = 0.0
    @State var prevLon: Double = 0.0
    @State var prevDir: Double = 0.0
    @State var currLat: Double = 0.0
    @State var currLon: Double = 0.0
    @State var currDir: Double = 0.0
    @State var showingGoodAlert = false
    @State var showingWrongAlert = false
    @State var showMap = false
    @State var completedStops = [String]()
    var db = Firestore.firestore()
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var auth: Authentication
    
    /*var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
    var direction: Double {
        return Double(locationManager.direction ?? 0.0)
    }*/
    
    func getCoordinatesAndDirection() {
        self.prevLat = self.currLat
        self.prevLon = self.currLon
        self.prevDir = self.currDir
        self.currLat = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.currLon = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
        self.currDir = Double(locationManager.direction ?? 0.0)
    }
    
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.getCoordinatesAndDirection()
        }
    }

    
    func getStops() {
        print("Getting stops for \(name)...")
        let stopRef = db.collection("hunts").document("\(String(describing: name))").collection("stops")
        
        stopRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.stops = [Stop]()
                print("Getting images for \(self.name)...")
                for document in querySnapshot!.documents {
                    
                    let storageRef = Storage.storage().reference()
                    let imgRef = storageRef.child("images/\(document.data()["imageName"] as! String)")
                    
                    
                    
                    
//                    print(document.data())
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double, Direction: document.data()["direction"] as! Double, distanceAway: Double(CLLocation(latitude: self.currLat, longitude: self.currLon).distance(from: CLLocation(latitude: document.data()["latitude"] as! Double, longitude: document.data()["longitude"] as! Double)))))
//                    print(self.stops)
//                    print("images: \(self.images)")
                    
                    
                    imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                        if let theError = error {print(theError); return}
//                        print("no error")
                        let imageNm = document.data()["imageName"] as! String
//                        print(imageNm)
                        self.images[imageNm] = UIImage(data: data!)!
//                        print("images: \(self.images)")
                    }
                    
                    
                }
//                print("IMAGES: \(self.images)")
            }
        }
        
    }
    
    func metersToMiles(meters: Double) -> Double {
        return Double(meters / 16.0934).rounded() / 100
    }
    
    func changeActionSheet() {
        self.showActionSheet.toggle()
    }
    
    func changeShowMap() {
        self.showMap.toggle()
    }
    
    func getPhotoCoordinatesAndDirection() {
        self.photoLatitude = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.photoLongitude = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
        self.photoDirection = Double(locationManager.direction ?? 0.0)
        //print("\(photoLatitude), \(photoLongitude)")
    }
    
    func calculateAngleToStop(yourLat: Double, yourLon: Double, stopLat: Double, stopLon: Double) -> Double {
        let deltaLat = stopLat - yourLat
        let deltaLon = stopLon - yourLon
        //print(deltaLat)
        //print(deltaLon)
        if deltaLat >= 0.0 {
            if deltaLat != 0.0 {
                //print(atan(deltaLon/deltaLat) * 180 / Double.pi)
                return atan(deltaLon/deltaLat) * 180 / Double.pi
            } else {
                //print(atan(deltaLon/deltaLat - 0.000001) * 180 / Double.pi)
            return atan(deltaLon/(deltaLat - 0.00001) * 180 / Double.pi)
            }
        } else {
            //print(atan(deltaLon/deltaLat) * 180 / Double.pi + 180)
            return atan(deltaLon/deltaLat) * 180 / Double.pi + 180
        }
    }
    
    func addCompletedStop(name: String) {
        
        db.collection("users").document("\(auth.currentEmail!)").collection("stopsCompleted").document("\(name)").setData(["name": self.name + "_" + name])

    }
    
    func getCompletedStops() {
        let stopRef = db.collection("users").document("\(auth.currentEmail!)").collection("stopsCompleted")
        
        stopRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //if (document.data()["name"] as! String).hasPrefix("\(self.name)") {
                        //print(document.data())
                        self.completedStops.append(document.data()["name"] as! String)
                        //print(self.stops)
                    //}
                }
            }
        }
    }
    
    func isMyPhotoRight(photoLat: Double, photoLon: Double, photoDir: Double, stopLat: Double, stopLon: Double, stopDir: Double, stopNam: String) {
        if abs(photoLat - stopLat) < 15.0 && abs(photoLon - stopLon) < 15.0 && abs(photoDir - stopDir) < 60.0 {
            self.addCompletedStop(name: stopNam)
            self.showingGoodAlert = true
        } else {
            self.showingWrongAlert = true
        }
        self.getCompletedStops()
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("").navigationBarTitle("").navigationBarHidden(true)
                if self.images.count > 0 && self.stops.count == images.count {
                    List {
                        ForEach(self.stops.sorted(by: {self.metersToMiles(meters: CLLocation(latitude: self.currLat, longitude: self.currLon).distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))) < self.metersToMiles(meters: CLLocation(latitude: self.currLat, longitude: self.currLon).distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude)))}), id: \.self) { stop in
                            
                            // This code is horrible but it works
                            
                            //NavigationLink(destination: CompleteAStop(stop: stop, images: self.images)) {
                            HStack {
                                VStack {
                                    Image(uiImage: self.images[stop.imgName]!).resizable()
                                        .frame(width: 120, height: 150).clipShape(RoundedRectangle(cornerRadius: 10))
                                    if self.completedStops.contains("\(self.name + "_" + stop.name)") {
                                        Text("Stop completed!").font(.custom("Averia-Regular", size: 10)).foregroundColor(.green).padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                                    }
                                }
                                VStack {
                                    Text("\(stop.name)").font(.custom("Averia-Regular", size: 26)).foregroundColor(.blue)
                                    if self.completedStops.contains("\(self.name + "_" + stop.name)") {
                                        Text("\(stop.stopDescription)").font(.custom("Averia-Regular", size: 18)).foregroundColor(.green)
                                    }
                                    HStack {
                                        ArrowView().rotationEffect(.degrees((self.calculateAngleToStop(yourLat: self.currLat, yourLon: self.currLon, stopLat: stop.latitude, stopLon: stop.longitude)) - self.currDir)).padding()
                                        Text("\(self.metersToMiles(meters: CLLocation(latitude: self.currLat, longitude: self.currLon).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))), specifier: "%.2f") miles away!").padding()
                                            .font(.custom("Averia-Regular", size: 18))
                                    }
                                    if self.metersToMiles(meters: CLLocation(latitude: self.currLat, longitude: self.currLon).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))) < 0.15 {
                                        Button(action: self.changeActionSheet) {
                                            ZStack {
                                                Rectangle()
                                                    .frame(width: 200, height: 24)
                                                    .foregroundColor(.gray)
                                                    .opacity(0.3)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                    Alert(title: Text("Congratulations!"), message: Text("You have successfully completed the stop and have unlocked its information!"), dismissButton: .default(Text("Got it!")))
                                }
                                .alert(isPresented: self.$showingWrongAlert) {
                                    Alert(title: Text("Not quite!"), message: Text("Make sure that you are facing the right way!"), dismissButton: .default(Text("Okay")))
                                }
                            }
                            //}
                        }
                    }
                .onAppear(perform: {_ = self.timer})
                } else {
                    Text("Loading stops...")
                }
                Button(action: self.changeShowMap) {
                    Text("Show Map >").padding().background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                }
                .sheet(isPresented: self.$showMap) {
                    VStack {
                        HuntStopsMap(email: "\(self.auth.currentEmail!)", name: self.name)
                        Button(action: self.changeShowMap) {
                            Text("Done")
                        }
                    }
                    
                }
            }.onAppear {self.getStops()}
                .onAppear { self.getCompletedStops() }
            
                .offset(y: -60)
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct HuntStops_Previews: PreviewProvider {
    static var previews: some View {
        HuntStops(name: "Trees")
    }
}
