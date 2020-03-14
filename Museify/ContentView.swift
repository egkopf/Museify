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

struct ContentView: View {
    @State var selectedView = 0
    var username: String

    var body: some View {
        TabView(selection: $selectedView) {
            UploadLogo()
                .tabItem {
                    Text("Search")
                        .font(.headline)
            }.tag(0)
            CreateAHunt()
                .tabItem {
                    Text("Create A Hunt")
                        .font(.headline)
            }.tag(1)
            Logo()
                .tabItem {
                    Text("Hunt Key")
                        .font(.headline)
            }.tag(2)
            Circle()
                .tabItem {
                    Text("Activity")
                        .font(.headline)
            }.tag(3)
            
            ProfilePage(username: self.username)
                .tabItem {
                    Text("Profile")
                        .font(.headline)
            }.tag(4)
        }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(username: "lunacoko@gmail.com")
    }
}
