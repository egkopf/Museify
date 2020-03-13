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
                Text("Museify").font(.largeTitle)
                
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
        }
    }
}

struct SignUpOrLogIn_Previews: PreviewProvider {
    static var previews: some View {
        SignUpOrLogIn()
    }
}
