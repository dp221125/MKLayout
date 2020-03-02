//
//  AppDelegate.swift
//  Sample
//
//  Created by Seokho on 2020/03/02.
//  Copyright © 2020 Seokho. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         
         let window = UIWindow(frame: UIScreen.main.bounds)
         self.window = window
         
         self.window?.rootViewController = ViewController()
         self.window?.makeKeyAndVisible()
         return true
     }

}

