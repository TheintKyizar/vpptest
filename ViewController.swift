//
//  ViewController.swift
//  vppTest
//
//  Created by Kyi Zar Theint on 8/29/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var dataDictionary = NSDictionary()
    var uuid:UUID!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        bluetoothManager.delegate = self as? CBPeripheralManagerDelegate
        locationManager.requestAlwaysAuthorization()
        monitor()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (success, error) in
            if success {
                print("granted noti")
            }
            else {
                print("denided noti")
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(sendnoti), name: NSNotification.Name(rawValue: "common"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendnotispec), name: NSNotification.Name(rawValue: "specific"), object: nil)
    }
    func addNotification(trigger: UNNotificationTrigger?, content:UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {
            (error) in
            if error != nil {
                print("error adding notigicaion: \(error!.localizedDescription)")
            }
        }
    }

    func sendnoti(){
        let content = UNMutableNotificationContent()
        content.title = "common"
        content.body = "common"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        addNotification(trigger: trigger, content: content, identifier: "common")

    }
    func sendnotispec(){
        let content = UNMutableNotificationContent()
        content.title = "specific"
        content.body = "specific"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        addNotification(trigger: trigger, content: content, identifier: "specific")

    }
    
    @IBAction func button(_ sender: UIButton) {
        self.broadcast()
    }
    func broadcast(){
        if bluetoothManager.state == .poweredOn {
            uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: 1, minor: 2, identifier: "abc")
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
        }
    }
    func monitor() {
        uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
        let newRegion = CLBeaconRegion(proximityUUID: uuid!, identifier:"abc")
       /* let newRegion = CLBeaconRegion(proximityUUID: 00112233-4455-6677-8899-aabbccddeeff , major: UInt16(classmate.major![i]) as CLBeaconMajorValue, minor: UInt16((classmate.minor?[i])!) as CLBeaconMinorValue, identifier: (classmate.student_id?[i].description)!)*/
        let newRegion1 = CLBeaconRegion(proximityUUID: uuid!, major: 1, minor: 2, identifier: "abc")
        locationManager.startMonitoring(for: newRegion)
        locationManager.startMonitoring(for: newRegion1)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did enter region!!! \(region.identifier)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("fg did determine state!!!!!")
        switch(state) {
        case .inside:print("fg inside \(region.identifier)")
        case .outside:print("fg outside \(region.identifier)")
        case .unknown:print("fg unknown \(region.identifier)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

