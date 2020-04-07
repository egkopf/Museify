//
//  ChooseCoverImage.swift
//  Museify
//
//  Created by Ethan Kopf on 4/3/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import Combine
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct ChooseCoverImage: View {
    var huntName: String
    var db = Firestore.firestore()
    @Binding var variable: Bool
    
    func addCoverImage() {
        self.variable.toggle()
    }
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button(action: self.addCoverImage) {
                Text("Add to Hunt >")
            }
        }
    }
}

//struct ChooseCoverImage_Previews: PreviewProvider {
//    static var previews: some View {
//        ChooseCoverImage(huntName: "mom")
//    }
//}
