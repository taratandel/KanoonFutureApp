//
//  kanooniEnter.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Khordad/07 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
class kanooniEnter: UIViewController {

    
    @IBOutlet weak var backGround: UIImageView!
    
    @IBOutlet weak var userShomarande: UITextField!
    
    @IBOutlet weak var loginInfo: UILabel!
    
    var isLoggedIn : [NSManagedObject] = []
    var userInfo = UserInfo()
    var gpCode : Int?

    @IBAction func kanooniEnterButton(_ sender: UIButton) {
        let shomarandes: String! = userShomarande.text!
        let shomarande = Int(shomarandes)!
        
        self.confirm(shomarande: shomarande){
            usersinfo, error in
            if usersinfo != nil {
                self.userInfo = usersinfo!
                self.saveToCoreData(usersinf: usersinfo!)
                
            }
            else if error != nil {
            
                self.loginInfo?.text = "شمارنده را صحیح وارد کنید"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self.loginInfo?.text = ""
                }
            }
            
        }
        


    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGround.image = #imageLiteral(resourceName: "kanooniEnter")
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func confirm(shomarande:Int!, completionHandler: @escaping (UserInfo?, Error?) ->()){
        
        let urlString = "http://city.kanoon.ir/newsite/common/webservice/wscitydata.asmx/RegisterFutureLookUserByCounterJson?counter=\(shomarande!)"
        
        Alamofire.request(urlString).responseJSON { response in
            
            if NetworkReachabilityManager()!.isReachable{
                switch response.result{
                case .success(let value):
                    if let result: NSDictionary = value as? NSDictionary{
                        
                        let userinfo = UserInfo()
                        
                        userinfo.firstName = result["FirstName"] as! String
                        userinfo.lastName = result["LastName"] as! String
                        userinfo.branchName = result["BranchName"] as! String
                        userinfo.groupCode = result["GroupCode"] as! Int
                        userinfo.id = result["Id"] as! Int
                        userinfo.sex = result["Sex"] as! Bool
                        userinfo.isKanooni = true
                        
                        completionHandler(userinfo, nil)
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
                
            else{
                self.loginInfo.text = "اینترنت خود را بررسی کنید"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self.loginInfo?.text = ""
                }
                self.loginInfo.textColor = UIColor.blue
                
            }
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "kanooniValidEnterSegue"{
            let viewset = segue.destination as! UITabBarController
            let mainview = viewset.viewControllers?[0] as! mainView
           mainview.usersInfo = userInfo
        }
    }
    func saveToCoreData( usersinf : UserInfo){
        if usersinf != nil {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName:"Shomarande",
                                           in: managedContext)!
            
            let person = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            
            person.setValue(userInfo.groupCode, forKeyPath: "shomare")
            person.setValue(userInfo.branchName, forKey: "branchName")
            person.setValue(userInfo.firstName, forKey: "firstName")
            person.setValue(Int((userShomarande?.text!)!)!, forKey: "id")
            person.setValue(userInfo.isKanooni, forKey: "isKanooni")
            person.setValue(userInfo.lastName, forKey: "lastName")
            person.setValue(userInfo.sex, forKey: "sex")
            
            // 4
            do {
                try managedContext.save()
                isLoggedIn.append(person)
                self.performSegue(withIdentifier: "kanooniValidEnterSegue", sender: self)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
    }

    
}
