//
//  HuntRow.swift
//  Museify
//
//  Created by Aron Korsunsky on 4/2/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct HuntRow: View {
    @State var name: String
    @State var description: String
    
    var body: some View {
        VStack{
            Text("\(name)")
                .font(.headline)
            Text("\(description)")
                .font(.body)
        }
    }
}

struct HuntRow_Previews: PreviewProvider {
    static var previews: some View {
        HuntRow(name: "Hello", description: "Goodbye")
    }
}
