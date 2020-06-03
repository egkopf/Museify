//
//  SignUpOrLogIn.swift
//  Museify
//
//  Created by Aron Korsunsky on 2/18/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import SwiftUI

struct SignUpOrLogIn: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 150)
                Logo().frame(width: 300, height: 300)
                Text("Museify").font(.custom("Averia-Regular", size: 36))
                
                VStack {
                    
                    NavigationLink(destination: SignUp()) {
                        Text("Create an Account")
                    }
                    
                    NavigationLink(destination: LogIn()) {
                        Text("Log In")
                    }
                    Spacer()
                }
            }
        }.font(.custom("Averia-Regular", size: 18))
    }
}

struct SignUpOrLogIn_Previews: PreviewProvider {
    static var previews: some View {
        SignUpOrLogIn()
    }
}
