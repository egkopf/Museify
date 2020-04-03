//
//  PhotoCaptureView.swift
//  Museify
//
//  Created by Ethan Kopf on 3/27/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct PhotoCaptureView: View {
    
    @Binding var showImagePicker: Bool
    @Binding var image: Image?
    
    
    var body: some View {
        ImagePicker(isShown: $showImagePicker, image: $image)
    }
}

struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false), image: .constant(Image("M.jpg")))
    }
}
