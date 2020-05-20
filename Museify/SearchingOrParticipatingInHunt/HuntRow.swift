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
        VStack(alignment: .leading) {
            Text("\(name)")
            Text("\(description)")
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct HuntRow_Previews: PreviewProvider {
    static var previews: some View {
        HuntRow(name: "Hello", description: "Goodbye")
    }
}
