//
//  Search.swift
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


struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

class Hunt: Identifiable, Equatable, CustomStringConvertible, Hashable {
    static func == (lhs: Hunt, rhs: Hunt) -> Bool {
        return lhs.name == lhs.name && lhs.description == lhs.description
    }
    
    var name: String
    var description: String
    var key: Int?
    var stops: [Stop]
    var closestStop: Double
    
    var id: String { name }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    init(name: String, description: String, key: Int?, stops: [Stop], closestStop: Double) {
        self.name = name
        self.description = description
        self.key = key
        self.stops = stops
        self.closestStop = closestStop
    }
}

struct Search: View {
    var db = Firestore.firestore()
    @State public var hunts = [Hunt]()
    @State public var searchBar = ""
    @State var privKey: String = ""
    @State var currentHuntName = ""
    @State var ready: Bool = false
    @State var images = [String: UIImage]()
    @State var completedStops = [String]()
    @State var huntsUnderway = [String]()
    @State var distancesGotten: Bool = false
    @EnvironmentObject var auth: Authentication
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
    func metersToMiles(meters: Double) -> Double {
        return Double(meters / 16.0934).rounded() / 100
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
                            if querySnapshot!.documents.count == self.hunts.count {
                                print("Getting images...")
                                self.getAllImages()
                            } else {
                            }
                            
                            
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
    
    func getAllImages() {
        let tempHunts = hunts.filter({$0.key == nil})
        if tempHunts.count == images.count {return}
        
        for hunt in hunts {
            if hunt.key == nil {
                let storageRef = Storage.storage().reference()
                let imgRef = storageRef.child("images/\(hunt.name)CoverImage")
                
                imgRef.getData(maxSize: 1 * 8000 * 8000) { data, error in
                    if let theError = error {print(theError); return}
                    //print("no error")
                    self.images[hunt.name] = UIImage(data: data!)!
                }
            }
            
        }
    }
    
    func huntstops(hunt: Hunt) -> Int {
        return hunt.stops.count
    }
    
    func getPrivHunt() {
        for hunt in self.hunts {
            if hunt.key == Int(privKey) {
                self.currentHuntName = hunt.name
                ready = true
            }
        }
        //print("no hunt")
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
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                if self.thereAreHunts() && self.thereAreStops() {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .onAppear {
                            self.calculateClosestStop(hunts: self.hunts, currLat: self.userLatitude, currLon: self.userLongitude)
                    }
                }
                Spacer().navigationBarTitle("").navigationBarHidden(true).frame(height: 40)
                HStack {
                    Logo().frame(width: 80)
                    Spacer().frame(width: 100)
                    ZStack {
                        Text("Hunts").font(.custom("Averia-Bold", size: 36)).offset(x: 2, y: 2).foregroundColor(.blue).opacity(0.22)
                        Text("Hunts").font(.custom("Averia-Bold", size: 36))
                    }
                }.padding().frame(width: 400, alignment: .leading)
                
                
                SearchBar(text: $searchBar, placeholder: "Search")
                
                if self.thereAreStops() && self.thereAreHunts() && self.distancesGotten {
                    List {
                        ForEach(hunts.sorted(by: { $0.closestStop < $1.closestStop})) { hunt in
                            if (hunt.name.lowercased().contains(self.searchBar.lowercased()) || hunt.description.lowercased().contains(self.searchBar.lowercased()) || self.searchBar == "") && (hunt.key == nil) {
                                ZStack {
                                    NavigationLink(destination: TabbedHuntStops(name: hunt.name)) {                                EmptyView()
                                    }.hidden()
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(hunt.name)").font(.custom("Averia-Bold", size: 18))
                                            Text("\(hunt.description)")
                                            Text("Closest Stop: \(self.metersToMiles(meters: hunt.closestStop), specifier: "%.2f") miles away").font(.custom("Averia-Bold", size: 12))
                                            
                                        }.font(.custom("Averia-Regular", size: 18))
                                        if self.completedStops.filter( { $0.starts(with: "\(hunt.name)") }).count == self.huntstops(hunt: hunt) {
                                            Text("Complete!").foregroundColor(.green).font(.custom("Averia-Bold", size: 12))
                                        } else {
                                            if self.completedStops.filter( { $0.starts(with: "\(hunt.name)") }).count > 0 {
                                                Text("Underway!").foregroundColor(.orange).font(.custom("Averia-Bold", size: 12))
                                            }
                                        }
                                        
                                        
                                            
                                        
                                        Spacer()
                                        
                                        if self.images[hunt.name] != nil {
                                            Image(uiImage: self.images[hunt.name]!).resizable()
                                                .frame(width: 50, height: 50, alignment: .trailing).clipShape(RoundedRectangle(cornerRadius: 10))
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(width: 400)
                    
                    VStack {
                        HStack {
                            Text("Enter a Private Hunt Key:")
                            TextField("enter", text: $privKey).frame(width: 60)
                            Button(action: self.getPrivHunt) {
                                Text("find")
                            }
                            VStack {
                                if currentHuntName != "" {
                                    Text(currentHuntName)
                                }
                                
                                NavigationLink(destination: HuntStops(name: currentHuntName)) {
                                    Text("embark")
                                }.disabled(currentHuntName == "")
                            }
                            
                            
                            
                        }.padding()
                    }.background(RoundedRectangle(cornerRadius: 25, style: .continuous).fill(Color.blue).opacity(0.12), alignment: .bottom)
                    Spacer().frame(height: 20)
                }
                
            }//.font(.custom("Averia-Regular", size: 18))
              .onAppear { self.getAllHunts() }
            .onAppear { self.getCompletedStops() }
            }.offset(y: -1).navigationBarBackButtonHidden(true)
    }
    
    struct Search_Previews: PreviewProvider {
        static var previews: some View {
            Search()
        }
    }
}
