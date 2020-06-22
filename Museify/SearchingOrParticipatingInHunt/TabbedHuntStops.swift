//////
//////  TabbedHuntStops.swift
//////  Museify
//////
//////  Created by Aron Korsunsky on 6/15/20.
//////  Copyright © 2020 Ethan Kopf. All rights reserved.
//////
////
//import SwiftUI
//
//struct TabbedHuntStops: View {
//    @State var selectedView = 0
//    @State var name: String
//
//    var body: some View {
//        TabView(selection: $selectedView) {
//            HuntStops(name: self.name)
//                .tabItem {
//                    Text("Search")
//                        .font(.system(size: 25))
//            }.tag(0)
//            HuntStopsMap(name: self.name)
//                .tabItem {
//                    Text("Map")
//                        .font(.system(size: 25))
//                    
//            }.tag(1)
//        }
//    }
//}
//
///*struct TabbedHuntStops_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedHuntStops()
//    }
//}*/
