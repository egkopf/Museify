//
//  HuntKey.swift
//  Museify
//
//  Created by Ethan Kopf on 3/27/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct HuntKey: View {
    @State var key = String()
    
    func findHunt() {
        print("looking for a hunt")
    }
    var body: some View {
        VStack {
            HStack {
                Text("Hunt Key:")
                TextField("Enter key", text: $key)
            }.frame(width: 200, alignment: .center)
            Button(action: self.findHunt) {
                Text("Find Hunt")
            }
        }
    }
}

struct HuntKey_Previews: PreviewProvider {
    static var previews: some View {
        HuntKey()
    }
}
