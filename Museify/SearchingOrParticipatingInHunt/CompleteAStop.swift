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
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var uiimage: UIImage?
    @State var sourceType: Int = 0
    @ObservedObject var locationManager = LocationManager()
    @State var userLatitude: Double = 0.0
    @State var userLongitude: Double = 0.0
    @State var statusString: String = ""
    
    func getLocation() {
        self.userLatitude = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.userLongitude = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
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
            ZStack {
                HStack {
                    Text("Take a picture:")
                    CameraButtonView(showActionSheet: $showActionSheet)
                        .actionSheet(isPresented: $showActionSheet, content: { () -> ActionSheet in
                            ActionSheet(title: Text("Select Image"), message: Text("Please select an image"), buttons: [
                                ActionSheet.Button.default(Text("Camera"), action: {
                                    self.sourceType = 0
                                    self.showImagePicker.toggle()
                                }),
                                ActionSheet.Button.default(Text("Photo Gallery"), action: {
                                    self.sourceType = 1
                                    self.showImagePicker.toggle()
                                }),
                                ActionSheet.Button.cancel()
                            ])
                        })
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(isVisible: self.$showImagePicker, uiimage: self.$uiimage, sourceType: self.sourceType, userLatitude: self.$userLatitude, userLongitude: self.$userLongitude, statusString: self.$statusString)
                    }
                    if self.uiimage != nil {
                        Image(uiImage: uiimage!).resizable().frame(width: 150, height: 150)
                    }
                }
            }
        }
        .onAppear { self.getLocation() }
    }
}

struct CompleteAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
