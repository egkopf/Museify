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
    @State var photoLatitude: Double = 0.0
    @State var photoLongitude: Double = 0.0
    @State var photoDirection: Double = 0.0
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: Double {
        return Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
    }
    var userLongitude: Double {
        return Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
    }
    var statusString: String {
        return locationManager.statusString
    }
    var direction: Double {
        return Double(locationManager.direction ?? 0.0)
    }
    
    func getPhotoCoordinatesAndDirection() {
        self.photoLatitude = Double(locationManager.lastLocation?.coordinate.latitude ?? 0.0)
        self.photoLongitude = Double(locationManager.lastLocation?.coordinate.longitude ?? 0.0)
        self.photoDirection = Double(locationManager.direction ?? 0.0)
        print("\(photoLatitude), \(photoLongitude)")
    }
    
    func isMyPhotoRight(photoLat: Double, photoLon: Double, photoDir: Double, stopLat: Double, stopLon: Double, stopDir: Double) -> Bool {
        if abs(photoLat - stopLat) < 10.0 && abs(photoLon - stopLon) < 10.0 && abs(photoDir - stopDir) < 60.0 {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack{
            HStack {
                Image(uiImage: self.images[stop.imgName]!).resizable()
                    .frame(width: 80, height: 120)
                VStack {
                    Text("\(stop.name)")
                        .font(.headline)
                        .fontWeight(.bold)
//                    Text("\(stop.stopDescription)")
//                        .font(.subheadline)
                    Text("\(CLLocation(latitude: self.userLatitude, longitude: self.userLongitude).distance(from: CLLocation(latitude: stop.latitude, longitude: stop.longitude))) meters away!")
                    Text("Your direction: \(self.direction)")
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
                            ImagePicker(isVisible: self.$showImagePicker, uiimage: self.$uiimage, sourceType: self.sourceType)
                                .onDisappear(perform: {self.getPhotoCoordinatesAndDirection()})
                    }
                    if self.uiimage != nil {
                        VStack{
                            Image(uiImage: uiimage!).resizable().frame(width: 80, height: 120)
                            Text("\(self.photoLatitude), \(self.photoLongitude)")
                            Text("\(self.photoDirection)")
                        }
                    }
                }
            }
            if self.uiimage != nil {
                if isMyPhotoRight(photoLat: self.photoLatitude, photoLon: self.photoLongitude, photoDir: self.photoDirection, stopLat: stop.latitude, stopLon: stop.longitude, stopDir: stop.direction) {
                    VStack {
                        Text("Congatualtions! You have completed this stop!")
                            .foregroundColor(.green)
                        Text("\(stop.stopDescription)")
                    }
                }
                if !isMyPhotoRight(photoLat: self.photoLatitude, photoLon: self.photoLongitude, photoDir: self.photoDirection, stopLat: stop.latitude, stopLon: stop.longitude, stopDir: stop.direction) {
                    Text("Sorry! Not quite...")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct CompleteAStop_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
