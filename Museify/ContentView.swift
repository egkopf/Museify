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
            CreateAHunt()
                .tabItem {
                    Image(systemName: "plus.app")
                        .font(.system(size: 25))
            }.tag(0)
            Search()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 25))
                    
            }.tag(1)
            ProfilePage(username: self.username)
                .tabItem {
                    Image(systemName: "person")
                        .font(.system(size: 25))
            }.tag(2)
        }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(username: "lunacoko@gmail.com")
    }
}
