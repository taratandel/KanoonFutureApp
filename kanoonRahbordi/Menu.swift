//
//  Menu.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Tir/20 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import CoreData




class MenuTableCell: UITableViewCell {
    
    @IBOutlet weak var menuImg: UIImageView!
    @IBOutlet weak var menuLbl: UILabel!
}

class Menu: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuTable: UITableView!
    
    var menuTitles=[ "سایر محصولات","درباره ما","خروج"]
    
    var menuImages: [UIImage] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        menuImages.append(UIImage(named: "menuImage1.png")!)
        menuImages.append(UIImage(named: "menuImage2.png")!)
        menuImages.append(UIImage(named: "menuImage3.png")!)
        menuImages.append(UIImage(named: "menuImage4.png")!)
        
        menuTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableCell
        cell.menuLbl.text = menuTitles[indexPath.row]
        cell.menuImg.image = menuImages[indexPath.row]
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            otherProducts()
        case 1:
            aboutUs()
        case 2:
            quitUser()
        default:
            break
            
        }
    }
    
    func otherProducts() {
        
        let alertController = UIAlertController(title: "Other Products:", message: "", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func aboutUs() {
        
        let alertController = UIAlertController(title: "درباره ما:", message: "http://github.com/negar95\nhttp://github.com/taratandel", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    func quitUser() {
        
        performSegue(withIdentifier: "quitToFirst", sender: self)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "quitToFirst"{
            //preparing coredata
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //fetching Datas
            
            let fechtRequest  = NSFetchRequest<NSManagedObject>(entityName: "Shomarande")
            
            //check if data exists or not
            do {
                //if exists fill the array
                let nationalCode = try managedContext.fetch(fechtRequest)
                for managedObject in nationalCode
                {
                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedContext.delete(managedObjectData)
                }
            } catch let error as NSError {
                print("Detele all data in IsLoggedIn error : \(error) \(error.userInfo)")
            }
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
