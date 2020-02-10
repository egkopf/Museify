//
//  ContentView.swift
//  Museify
//
//  Created by Ethan Kopf on 1/31/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var selectedView = 0
    var body: some View {
        TabView(selection: $selectedView) {
            Rectangle()
                .tabItem {
                    Text("Search")
                        .font(.headline)
            }.tag(0)
            Circle()
                .tabItem {
                    Text("Create")
                        .font(.headline)
            }.tag(1)
            Rectangle()
                .tabItem {
                    Text("Hunt Key")
                        .font(.headline)
            }.tag(2)
            Circle()
                .tabItem {
                    Text("Activity")
                        .font(.headline)
            }.tag(3)
            Rectangle()
                .tabItem {
                    Text("Profile")
                        .font(.headline)
            }.tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
