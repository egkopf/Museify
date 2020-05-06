//
//  CameraButtonView.swift
//  CameraPractice
//
//  Created by Aron Korsunsky on 5/6/20.
//  Copyright © 2020 Aron Korsunsky. All rights reserved.
//

import SwiftUI

struct CameraButtonView: View {
    @Binding var showActionSheet: Bool
    var body: some View {
        Button(action: {self.showActionSheet.toggle()}) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 38, height: 38, alignment: .center)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 36, height: 36, alignment: .center)
                        .foregroundColor(.gray))
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundColor(.black))
            
        }
    }
}

struct CameraButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CameraButtonView(showActionSheet: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
