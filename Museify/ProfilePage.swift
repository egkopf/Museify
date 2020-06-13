//
//  ProfilePage.swift
//  Museify
//
//  Created by Ethan Kopf on 2/29/20.
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

struct ProfilePage: View {
    var username: String
    @EnvironmentObject var auth: Authentication
    var db = Firestore.firestore()
    @State var theStops = [(String, String)]()
    
    var huntsStarted: [String] {
        var hunts = [String]()
        for pair in theStops {
            if hunts.isEmpty {hunts.append(pair.0)}
            for stop in hunts {
                if stop == pair.0 {
                    break
                }
                hunts.append(pair.0)
            }
        }
        return hunts
    }
    
    private func getDocument() {
        db.collection("users").document(auth.currentEmail!).collection("stopsCompleted").getDocuments() { (stopsRef, err) in
            if let err = err {print("Error getting documents: \(err)")} else {
                self.theStops = []
                for stop in stopsRef!.documents {
                    let stopName = stop.data()["name"] as! String
                    let stopNameArr = stopName.components(separatedBy: "_")

                    let huntName: String = stopNameArr[0]
                    let jstopName: String = stopNameArr[1]
                    self.theStops.append((huntName, jstopName))
                }
            }
        }

    }
    
    var body: some View {
        VStack {
            
            Logo().frame(width: 200)
            Text("My Profile").font(.custom("Averia-Bold", size: 28))
            Text("\(username)\n").font(.custom("Averia-Regular", size: 20))
            Text("My Hunts").font(.custom("Averia-Bold", size: 28))
//            if (!(theStops.isEmpty)) {
//                ScrollView {
//                    ForEach(0..<self.theStops.count) { index in
//                        HStack {
//                            ZStack {
//                                Rectangle()
//                                .frame(width: 200, height: 24)
//                                .foregroundColor(.gray)
//                                .opacity(0.3)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                                Text(self.theStops[index].0 + ": " + self.theStops[index].1)
//                            }
//
//
//
//                        }
//
//                    }
//                }
//            }
            if (!(huntsStarted.isEmpty)) {
                ScrollView {
                    ForEach(0..<self.huntsStarted.count, id: \.self) { index in
                        Group {
                            VStack {
                                ZStack {
                                    Rectangle()
                                    .frame(width: 200, height: 24).foregroundColor(.gray).opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 10))
                                    Text(self.huntsStarted[index])
                                }
                                
//                                ForEach(0..<self.theStops.count, id: \.self) { indexTwo in
//                                    VStack {
//                                        if self.theStops[indexTwo] == self.huntsStarted[index] {
//                                            //Text(self.theStops[indexTwo])
//                                        }
//                                        Text("")
//                                    }
//
//                                }
                            }
                        }
                        
                        
                        
                        
                    }
                }
            }
            
        }.font(.custom("Averia-Regular", size: 18)).onAppear {
            self.getDocument()
            
        }
    }
}
    

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
