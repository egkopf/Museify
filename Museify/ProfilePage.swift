//
//  ProfilePage.swift
//  Museify
//
//  Created by Ethan Kopf on 2/29/20.
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

struct ProfilePage: View {
    var username: String
    var body: some View {
        VStack {
            Text("Profile").font(.largeTitle)
            Text("Welcome \(username)")
        }
    }
}
    

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        Circle()
    }
}
