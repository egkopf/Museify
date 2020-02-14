//
//  Logo.swift
//  Museify
//
//  Created by Ethan Kopf on 2/14/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        ZStack {
            Image("M")
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
        }
    }
}

struct Logo_Previews: PreviewProvider {
    static var previews: some View {
        Logo()
    }
}
