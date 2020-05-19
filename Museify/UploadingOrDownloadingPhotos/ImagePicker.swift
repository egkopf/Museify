//
//  ImagePicker.swift
//  CameraPractice
//
//  Created by Aron Korsunsky on 5/6/20.
//  Copyright © 2020 Aron Korsunsky. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    @Binding var uiimage: UIImage?
    var sourceType: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isVisible: $isVisible, uiimage: $uiimage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.sourceType = sourceType == 1 ? .photoLibrary : .camera
        
        vc.delegate = context.coordinator
        
        return vc
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @Binding var isVisible: Bool
        @Binding var uiimage: UIImage?
        
        init(isVisible: Binding<Bool>, uiimage: Binding<UIImage?>) {
            _isVisible = isVisible
            _uiimage = uiimage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            uiimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            //image = Image(uiImage: uiimage)
            isVisible = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isVisible = false
        }
    }
}
