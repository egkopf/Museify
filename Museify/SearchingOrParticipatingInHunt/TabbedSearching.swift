//
//  TabbedSearching.swift
//  Museify
//
//  Created by Aron Korsunsky on 6/15/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct TabbedSearching: View {
    @State var selectedView = 0

    var body: some View {
        TabView(selection: $selectedView) {
            Search()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        .font(.system(size: 25))
                        Text("List of Hunts")
                    }
                    
            }.tag(0)
            MapSearching()
                .tabItem {
                    VStack {
                        Image(systemName: "mappin")
                        .font(.system(size: 25))
                        Text("Map of Hunts")
                    }
                    
            }.tag(1)
        }
    }
}

struct TabbedSearching_Previews: PreviewProvider {
    static var previews: some View {
        TabbedSearching()
    }
}
