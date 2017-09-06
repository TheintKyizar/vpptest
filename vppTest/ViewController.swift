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
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var dataDictionary = NSDictionary()
    var uuid:UUID!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")
        let region = CLBeaconRegion(proximityUUID: uuid, major: UInt16(1), minor: UInt16(2), identifier: "2")
        delegate.locationManager.stopMonitoring(for: region)
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func login(){
        let this_device = UIDevice.current.identifierForVendor?.uuidString
        let parameters:[String:Any] = [
            "username" : "canhnht",
            "password" : "123456",
            "device_hash" : this_device!
        ]
        
        //Set up SpinnerView
        let alertController = UIAlertController(title: "Loging in", message: "Please wait...\n\n", preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
        
        //Use the api to login
        Alamofire.request(Constant.URLstudentlogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response:DataResponse) in
            
            //Check the status code return from the api
            let code = response.response?.statusCode
            if code == 200{
                
                print("Login success")
                UserDefaults.standard.set("canhnht", forKey: "username")
                UserDefaults.standard.set("123456", forKey: "password")
                
                //retrieve JSON data
                if let JSON = response.result.value as? [String: AnyObject]{
                    
                    Constant.token = JSON["token"] as! String
                    UserDefaults.standard.set(JSON["token"] as! String, forKey: "token")
                    Constant.student_id = JSON[ "id"] as! Int
                    UserDefaults.standard.set(Constant.student_id, forKey: "student_id")
                    //Check if the device is new
                    
                }
            }else{
                alertController.dismiss(animated: false, completion: nil)
                print("Login failed")
            }
        })
        
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
    
}

class Student{
    
    var major:Int?
    var minor:Int?
    var id:Int?
    
}

struct GlobalData{
    static var string = "Not set"
    static var students = [Student]()
    static var regions = [CLBeaconRegion]()
    static var tempRegions = [CLBeaconRegion]()
    static var flags = Bool()
}

struct Constant{
    static let baseURL = "http://188.166.247.154/atk-ble/"
    static let URLatk = baseURL + "api/web/index.php/v1/beacon-attendance-student/student-attendance"
    static let URLstudentlogin = baseURL + "api/web/index.php/v1/student/login"
    
    static var identifier = Int()
    static var token = String()
    static var student_id = Int()
    static var student_id2 = Int()
    static var studentGroup = Int()
    static var currentGroup = Int()
    
}


