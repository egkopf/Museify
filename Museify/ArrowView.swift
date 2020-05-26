//
//  ArrowView.swift
//  Museify
//
//  Created by Aron Korsunsky on 5/21/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct ArrowView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 5, height: 45)
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 5, height: 17)
                .rotationEffect(.degrees(40))
                .offset(x: -4, y: -19)
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 5, height: 17)
                .rotationEffect(.degrees(-40))
                .offset(x: 4, y: -19)
        }
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowView()
    }
}
