//
//  CompleteAStop.swift
//  Museify
//
//  Created by Aron Korsunsky on 4/16/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI
import CoreLocation

struct CompleteAStop: View {
    @State var stop: Stop
    @State var images: [String: UIImage]
    @ObservedObject var locationManager = LocationManager()

    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }

    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    
    var body: some View {
        VStack{
            HStack {
                Image(uiImage: self.images[stop.imgName]!).resizable()
                    .frame(width: 150, height: 200)
                VStack {
                    Text("\(stop.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("\(stop.stopDescription)")
                        .font(.subheadline)
                    Text("\(CLLocation(latitude: userLatitude, longitude: userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))) meters away!")
                }
            }
            ChooseImageFromLib()
        }
    }
}

struct CompleteAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
