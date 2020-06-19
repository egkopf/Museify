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
                Spacer().frame(height: 100)
                Logo().frame(width: 300, height: 300)
                Text("Museify").font(.custom("Averia-Regular", size: 36))
                
                VStack {
                    Spacer().frame(height: 15)
                    
                    NavigationLink(destination: LogIn()) {
                        Text("Log In").padding(.all, 7.0).background(RoundedRectangle(cornerRadius: 5).foregroundColor(.gray).opacity(0.2))
                    }
                    Spacer().frame(height: 15)
                    
                    NavigationLink(destination: SignUp()) {
                        Text("Create an Account").padding(.all, 7.0).background(RoundedRectangle(cornerRadius: 5).foregroundColor(.gray).opacity(0.2))
                    }
                    
                    
                    
                    Spacer().navigationBarTitle("")
                    //.navigationBarHidden(true)
                }
            }
        }.padding().font(.custom("Averia-Regular", size: 18))
    }
}

struct SignUpOrLogIn_Previews: PreviewProvider {
    static var previews: some View {
        SignUpOrLogIn()
    }
}
