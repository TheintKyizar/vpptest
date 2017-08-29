//
//  AppDelegate.swift
//  vppTest
//
//  Created by Kyi Zar Theint on 8/29/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var identifier: UIBackgroundTaskIdentifier! = UIBackgroundTaskInvalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        bluetoothManager.delegate = self as? CBPeripheralManagerDelegate
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            registerBackgroundTask()
            self.locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
        case .outside: print("Outside bg")
        case .unknown: print("UNKNOWN")
    }
    }
    func registerBackgroundTask(){
        identifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(identifier != UIBackgroundTaskInvalid)
    }
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(identifier)
        self.identifier = UIBackgroundTaskInvalid
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Ranging")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "common"), object: nil)
    }
    
    /*func beginBackgroundTask(withName: "abc", expirationHandler: (()-> Void)? = nil) {
    }*/
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        registerBackgroundTask()
        endBackgroundTask()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

