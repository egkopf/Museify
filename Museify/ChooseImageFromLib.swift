//
//  ChooseImageFromLib.swift
//  Museify
//
//  Created by Ethan Kopf on 3/27/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct ChooseImageFromLib: View {
    @State private var showImagePicker: Bool = false
    @State private var image: Image? = nil
    var body: some View {
        VStack {
            
            image?.resizable()
                .scaledToFit()
            
            Button("Open Camera") {
                self.showImagePicker = true
            }
        }.sheet(isPresented: self.$showImagePicker) {
            PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$image)
        }
    }
}

struct ChooseImageFromLib_Previews: PreviewProvider {
    static var previews: some View {
        ChooseImageFromLib()
    }
}
