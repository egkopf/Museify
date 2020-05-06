//
//  ContentView.swift
//  CameraPractice
//
//  Created by Aron Korsunsky on 5/6/20.
//  Copyright © 2020 Aron Korsunsky. All rights reserved.
//

import SwiftUI

struct UsingCamera: View {
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var uiimage: UIImage?
    @State var sourceType: Int = 0
    
    var body: some View {
        //var image = Image(uiImage: uiimage!)
        ZStack {
            Image(uiImage: uiimage!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
                .overlay(
            CameraButtonView(showActionSheet: $showActionSheet))
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
            if showImagePicker {
                ImagePicker(isVisible: $showImagePicker, uiimage: $uiimage, sourceType: sourceType)
            }
            
        }
        //.onAppear { self.image = Image(systemName: "star.fill")}
    }
}

struct UsingCamera_Previews: PreviewProvider {
    static var previews: some View {
        UsingCamera()
    }
}
