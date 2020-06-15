//
//  MapSearching.swift
//  MapView
//
//  Created by Aron Korsunsky on 6/14/20.
//  Copyright © 2020 Aron Korsunsky. All rights reserved.
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

struct MapSearching: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [MKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var isShowing = false
    @ObservedObject var locationManager = LocationManager()
    var db = Firestore.firestore()
    @State public var hunts = [Hunt]()
    @State var distancesGotten: Bool = false
    
    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
    func thereAreHunts() -> Bool {
        return (hunts.count > 2)
    }
    
    func thereAreStops() -> Bool {
        for hunt in hunts {
            if hunt.stops.count == 0 {
                return false
            }
        }
        return true
    }
    
    func getAllHunts() {
            hunts = []
            db.collection("hunts").getDocuments() { (querySnapshot, err) in
                if let err = err {print("Error getting documents: \(err)")} else {
                    print("Getting hunts...")
                    for hunt in querySnapshot!.documents {
                        var huntStops = [Stop]()
                        self.db.collection("hunts").document("\(hunt.data()["name"] as! String)").collection("stops").getDocuments() { (gotStops, stopsErr) in
                            if let stopsError = stopsErr {print("Error getting documents: \(stopsError)")} else {
                                for stop in gotStops!.documents {
                                    huntStops.append(Stop(Name: stop.data()["name"] as! String, StopDescription: stop.data()["description"] as! String, ImgName: stop.data()["imageName"] as! String, Latitude: stop.data()["latitude"] as! Double, Longitude: stop.data()["longitude"] as! Double, Direction: stop.data()["direction"] as! Double, distanceAway: 0.0))
                                }
                                
                                let newHunt = Hunt(name: hunt.data()["name"] as! String, description: hunt.data()["description"] as! String, key: (hunt.data()["huntID"] as? Int), stops: huntStops, closestStop: 0.0)
                                self.hunts.append(newHunt)
                                
                                
                                // THIS IS VERY RISKY but it seems to work
                                
    //                            if querySnapshot!.documents.count == self.hunts.count {self.getAllImages()} else {
    //                                print("QS dox: \(querySnapshot!.documents.count)")
    //                                print("Hunts dox: \(self.hunts.count)")
    //                            }
                            }
                        }
                        
                    }
                    
                }
            }
        }
    
    func calculateClosestStop(hunts: [Hunt], currLat: Double, currLon: Double) {
        print("Calculating closest stops...")
        for hunt in hunts {
            var distances = [Double]()
            for stop in hunt.stops {
                distances.append(Double(CLLocation(latitude: currLat, longitude: currLon).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))))
            }
            hunt.closestStop = distances.min()!
        }
        self.distancesGotten = true
        
    }
    
    func setLocations(hunts: [Hunt]) {
        var lat = Double()
        var lon = Double()
        for hunt in hunts {
            for stop in hunt.stops {
                if abs((Double(CLLocation(latitude: self.userLatitude, longitude: self.userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude)))) - hunt.closestStop) < 50.0 {
                    lat = stop.latitude
                    lon = stop.longitude
                }
            }
            self.locations.append(MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), title: hunt.name, subtitle: hunt.description))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if self.thereAreHunts() && self.thereAreStops() {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .onAppear {
                            self.calculateClosestStop(hunts: self.hunts, currLat: self.userLatitude, currLon: self.userLongitude)
                    }
                }
                if self.distancesGotten {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .onAppear {self.setLocations(hunts: self.hunts) }
                }
                ZStack {
                    VStack {
                        MapView(centerCoordinate: self.$centerCoordinate, selectedPlace: self.$selectedPlace, showingPlaceDetails: self.$showingPlaceDetails, annotations: self.locations)
                            .edgesIgnoringSafeArea(.all)
                    }.frame(height: self.isShowing ? 0.0 : geometry.size.height)
                }
                NavigationView {
                    NavigationLink(destination: TabbedHuntStops(name: self.selectedPlace?.title ?? "Forest"), isActive: self.$isShowing) { EmptyView()
                    }.hidden()
                }.frame(height: self.isShowing ? geometry.size.height : 0.0)
            }
            .onAppear { self.getAllHunts() }
            
                .alert(isPresented: self.$showingPlaceDetails) {
                    Alert(title: Text(self.selectedPlace?.title ?? "Unknown"), message: Text(self.selectedPlace?.subtitle ?? "Missing place information"), primaryButton: .default(Text("Go to hunt")) {
                        self.isShowing.toggle()
                        }, secondaryButton: .cancel())
            }
        }
    }
}

struct MapSearching_Previews: PreviewProvider {
    static var previews: some View {
        MapSearching()
    }
}
