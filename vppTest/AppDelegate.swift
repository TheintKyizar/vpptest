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
import Alamofire
import SwiftyTimer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var identifier: UIBackgroundTaskIdentifier! = UIBackgroundTaskInvalid
    var uuid:UUID!
    
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        bluetoothManager.delegate = self as? CBPeripheralManagerDelegate
        setupStudents()
        monitor()
        return true
    }
    
    func monitor() {
        
        var newRegion:CLBeaconRegion?
        uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
        if GlobalData.students.count > 20{
            Constant.studentGroup = GlobalData.students.count/20
            Constant.currentGroup = 1
            for i in 0...GlobalData.students.count-1{
                newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.students[i].major!), minor: UInt16(GlobalData.students[i].minor!), identifier: String(GlobalData.students[i].id!))
                if i<19{
                    locationManager.startMonitoring(for: newRegion!)
                    print(i)
                    GlobalData.tempRegions.append(newRegion)
                }
                
                GlobalData.regions.append(newRegion!)
            }
            newRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
            locationManager.startMonitoring(for: newRegion!)
            GlobalData.tempRegions.append(newRegion)
        }
        
    }
    
    private func setupStudents(){
        
        GlobalData.students.removeAll()
        
        for i in 1...40{
            let newStudent = Student()
            newStudent.major = 1
            newStudent.minor = i
            newStudent.id = i
            GlobalData.students.append(newStudent)
        }
        
    }
    /*func requestStateForMonitoredRegions() {
        for i in 0...GlobalData.tempRegions.count {
            locationManager.requestState(for: GlobalData.tempRegions[i])
        }
    }*/
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        var status = ""
        switch state {
        case .inside:
            status = "inside"
            print(region.identifier)
            if region.identifier == "common"{
                self.requestStateForMonitoredRegions()
                if GlobalData.flags == false{
                    self.checkRegion()
                }else{
                    GlobalData.flags = false
                }
                
            }else{
                print("Entered specific")
                self.stopMonitor(region: region as! CLBeaconRegion)
                GlobalData.flags = true
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "specific"), object: nil)
                
            }
        case .outside:
            status = "outside"
            print("Outside \(region.identifier)")
        case .unknown:
            status  = "unknown"
            print("UNKNOWN")
        }
        if region.identifier == "common"{
            GlobalData.regionStatus[19] = status
        }else{
            for i in 0...GlobalData.tempRegions.count - 1{
                if GlobalData.tempRegions[i]?.identifier == region.identifier{
                    GlobalData.regionStatus[i] = status
                }
            }
        }
    }
    
    func registerBackgroundTask() {
        print("Register background task")
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    private func stopMonitor(region: CLBeaconRegion){
        uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
        for i in GlobalData.students{
            if region.identifier == String(describing: i.id){
                let newRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(i.major!), minor: UInt16(i.minor!), identifier: String(describing:i.id))
                locationManager.stopMonitoring(for: newRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("Started monitoring \(region.identifier) region")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        
        print("Stop monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did exit region!!! \(region.identifier)")
            GlobalData.flags = false
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                appDelegate.locationManager.stopRangingBeacons(in: region as! CLBeaconRegion )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did enter region!!! \(region.identifier)")
        }
    }
    
    private func checkRegion(){
        print("Refreshing")
        print("Current group \(Constant.currentGroup)")
        print(Constant.studentGroup)
        for i in GlobalData.regions{
            self.locationManager.stopMonitoring(for: i)
        }
        GlobalData.tempRegions.removeAll()
        let state = Constant.studentGroup
        var check = Bool()
        for i in 1...state{
            if Constant.currentGroup == i{
                if i == state && check == false{
                    Constant.currentGroup = 1
                    check = true
                }else{
                    if check == false{
                        Constant.currentGroup = i + 1
                        check = true
                    }
                }
            }
        }
        print("Next group \(Constant.currentGroup)")
        self.refreshStudents()
        
    }
    
    private func refreshStudents(){
        let uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
        let start = (Constant.currentGroup - 1)*19
        if (GlobalData.students.count - start) > 19 {
            for i in 0...18{
                let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.students[i+start].major!), minor: UInt16(GlobalData.students[i+start].minor!), identifier: String(GlobalData.students[i+start].id!))
                locationManager.startMonitoring(for: newRegion)
                GlobalData.tempRegions.append(newRegion)
            }
        }
        
    }
    
    func checkStudent(major:Int,minor:Int) -> Int{
        
        if (major == 1) && (minor == 2) {
            return 5
        }else if major==1 && minor == 3{
            return 7
        }else{
            return 0
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        /*print("Number of beacons : \(beacons.count)")
         for i in beacons{
         print("Ranging \(String(describing: i.major)) + \(String(describing: i.minor))")
         GlobalData.string = String(describing: region.proximityUUID) + " " + String(describing: region.major) + " " + String(describing: region.minor) + " " + String(describing: i.major) + " " + String(describing: i.minor)
         Constant.student_id2 = checkStudent(major: Int(i.major), minor: Int(i.minor))
         takeAttendance()
         }
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "common"), object: nil)
         self.locationManager.stopRangingBeacons(in: region)*/
    }
    
    func takeAttendance() {
        print(" bg Inside \(Constant.identifier)");
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        Constant.student_id = UserDefaults.standard.integer(forKey: "student_id")
        
        let para1: Parameters = [
            "lesson_date_id": "31864",
            "student_id_1": Constant.student_id,
            "student_id_2": Constant.student_id2,
            ]
        
        
        let parameters: [String: Any] = ["data": [para1]]
        
        print(parameters)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constant.URLatk, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            let statusCode = response.response?.statusCode
            if (statusCode == 200){
                print("Attendance taken successful")
            }
            if let data = response.result.value{
                print("///////////////result below////////////")
                print(data)
            }
            
        }
        
    }
    
    func requestStateForMonitoredRegions() {
       Timer.after(5) { 
            for i in 0...GlobalData.tempRegions.count - 1{
                self.locationManager.requestState(for: GlobalData.tempRegions[i]!)
            }
            self.locationManager.requestState(for: GlobalData.tempRegions[19]!)
        }
    }
    
    /*func beginBackgroundTask(withName: "abc", expirationHandler: (()-> Void)? = nil) {
     }*/
    
    private func registerBackgroudTaskAgian(){
        registerBackgroundTask()
        var count = 0
        Timer.every(1) { 
            print(count)
            count += 1
            if count >= 160 && count/160 == 0 {
                self.registerBackgroudTaskAgian()
            }
            self.requestStateForMonitoredRegions()
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("schculed timer")
        registerBackgroundTask()
        var count = 0
        Timer.every(1) {
            print(count)
            count += 1
            if count >= 160 && count/160 == 0 {
                self.registerBackgroudTaskAgian()
            }
            self.requestStateForMonitoredRegions()
        }
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

