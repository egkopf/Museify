//
//  AppDelegate.swift
//  Museify
//
//  Created by Ethan Kopf on 1/31/20.
//  Copyright © 2020 Ethan Kopf. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let _ = Firestore.firestore()
        /*let storageRef = Storage.storage().reference()
        let localFile = URL(string: "M.jpg")!

        // Create a reference to the file you want to upload
        let logoRef = storageRef.child("images/logos.jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = logoRef.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
        }*/
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

class Stop: CustomStringConvertible, Hashable {

    static func == (lhs: Stop, rhs: Stop) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var name: String
    var imgName: String
    init(Name: String = "stopName", ImgName: String = "stopImg") {
        name = Name
        imgName = ImgName
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    var description: String {
        return "|name: \(name), imageName: \(imgName)|"
    }
}
