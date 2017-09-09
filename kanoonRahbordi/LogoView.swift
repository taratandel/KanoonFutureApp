//
//  LogoView.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Khordad/16 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import CoreData
class LogoView: UIViewController {

    var loginCheck: [NSManagedObject] = []
    
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shomarande")
        
        //3
        do {
            loginCheck = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if loginCheck.count > 0 {
            let loginChecks = loginCheck[0]
            
            let islogedin: Int! = loginChecks.value(forKey: "shomare") as! Int
            if islogedin != nil {
                self.navigationController?.navigationItem.hidesBackButton = true
                self.performSegue(withIdentifier: "loggedIn", sender: self)
                
            }
            else {
                return
            }
            
        }else {
            self.performSegue(withIdentifier: "notLoggedIn", sender: self)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
