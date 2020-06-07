//
//  HuntRow.swift
//  Museify
//
//  Created by Aron Korsunsky on 4/2/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct HuntRow: View {
    @Binding var hunt: Hunt
    @Binding var completedStops: [String]
    @Binding var distance: Double
    @Binding var images: [String: UIImage]
    
    func metersToMiles(meters: Double) -> Double {
        return Double(meters / 16.0934).rounded() / 100
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(hunt.name)").font(.custom("Averia-Bold", size: 18))
                Text("\(hunt.description)")
        
            }.font(.custom("Averia-Regular", size: 18))
            if self.completedStops.contains { $0.hasPrefix("\(hunt)") } {
                Text("Underway").foregroundColor(.green).font(.custom("Averia-Bold", size: 16))
            }
            Spacer()
            Text("Closest Stop: \(self.metersToMiles(meters: distance)) miles away").font(.custom("Averia-Bold", size: 12))
            Spacer()
            if self.images[hunt.name] != nil {
                Image(uiImage: self.images[hunt.name]!).resizable()
                    .frame(width: 50, height: 50, alignment: .trailing).clipShape(RoundedRectangle(cornerRadius: 10))
                
            }
            
        }

    }
}

/*struct HuntRow_Previews: PreviewProvider {
    static var previews: some View {
        HuntRow(name: "Hello", description: "Goodbye")
    }
}*/
