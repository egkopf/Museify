//
//  HuntStopsMap.swift
//  Museify
//
//  Created by Aron Korsunsky on 6/15/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import MapKit
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

struct HuntStopsMap: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [MKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var isShowing = false
    @ObservedObject var locationManager = LocationManager()
    var db = Firestore.firestore()
    @State public var name: String
    @State var stops = [Stop]()
    
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
                    self.stops.append(Stop(Name: document.data()["name"] as! String, StopDescription: document.data()["description"] as! String, ImgName: document.data()["imageName"] as! String, Latitude: document.data()["latitude"] as! Double, Longitude: document.data()["longitude"] as! Double, Direction: document.data()["direction"] as! Double, distanceAway: 0.0))
                    //                    print(self.stops)
                    //                    print("images: \(self.images)")
                    
                    
                    /* imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                     if let theError = error {print(theError); return}
                     //                        print("no error")
                     let imageNm = document.data()["imageName"] as! String
                     //                        print(imageNm)
                     self.images[imageNm] = UIImage(data: data!)!
                     //                        print("images: \(self.images)")
                     }*/
                    
                    
                }
                //                print("IMAGES: \(self.images)")
            }
        }
        
    }
    
    func setLocations(stops: [Stop]) {
        for stop in stops {
            self.locations.append(MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude), title: stop.name, subtitle: stop.description))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    VStack {
                        MapView(centerCoordinate: self.$centerCoordinate, selectedPlace: self.$selectedPlace, showingPlaceDetails: self.$showingPlaceDetails, annotations: self.locations)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                }
            .onAppear { self.getStops() }
            .onAppear { self.setLocations(stops: self.stops) }
                
            .alert(isPresented: self.$showingPlaceDetails) {
                Alert(title: Text(self.selectedPlace?.title ?? "Unknown"), message: Text(self.selectedPlace?.subtitle ?? "Missing place information"), dismissButton: .default(Text("Complete the stop in the list!")) )
            }
        }
    }
}

/*struct HuntStopsMap_Previews: PreviewProvider {
 static var previews: some View {
 HuntStopsMap()
 }
 }*/
