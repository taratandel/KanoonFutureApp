//
//  mainView.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Khordad/09 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class CourseNameTableViewCell : UITableViewCell{
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var khatchin: UIImageView!
    @IBOutlet weak var coursePages: UILabel!
    
}

class CourseInfo {
    public var courseId = Int()
    public var documentCount = Int()
    public var courseIdForQuiz = Int()
    public var FromPage = Int()
    public var ToPage = Int()
    public var courseName  = String()
}

class mainView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var courseListTableView: UITableView!
    @IBOutlet weak var monthText: UILabel!
    
    @IBOutlet weak var nameOfTheYear: UIImageView!
    @IBOutlet weak var yeartext: UILabel!
    @IBOutlet weak var backimage: UIImageView!
    
    let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
    let refreshButt : UIButton = UIButton(frame: CGRect(x: 137.5, y: 430, width: 100, height: 50))
    // 275
    var groupCode : Int!
    var Courses:[String] = []
    var row = Int()
    var coursss : [String] = []
    var idc : [Int] = []
    var idcc : [Int] = []
    var loginCheck: [NSManagedObject] = []
    var courseinfo = [CourseInfo]()
    var usersInfo = UserInfo()
    var selectedCourseId = Int()
    var selectedCourseIdForQuiz = Int()
    var dateValue = String()
    var flag = Bool()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
            print("Landscape")
        }
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        flag = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        flag = false
        
        
        // Show the navigation bar on other view controllers
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
            print("Landscape")
        }
        flag = true
        refreshButt.backgroundColor = UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        refreshButt.fullyRound(diameter: 10, borderColor: .black, borderWidth: 0)
        refreshButt.setTitle("تلاش مجدد", for: .normal)
        refreshButt.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        refreshButt.isHidden = true
        refreshButt.tag = 1
        self.view.addSubview(refreshButt)
        
        downloadExamDate{
            response, error in
            if response != nil{
                self.monthText?.text = self.turningDate(dateArray: response!)
                self.monthText.textColor = UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
            //    self.monthText.fullyRound(diameter: 10, borderColor: UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1), borderWidth: 1)
            }
        }
        fetchingDataFromCoreData()
        
        self.courseListTableView.separatorStyle = .none
        
        downloadTags(code: groupCode){
            coursinf,  error in
            if coursinf != nil {
                self.courseinfo.append(coursinf!)
                self.courseListTableView.reloadData()
                
            }
            else {
                self.refreshButt.isHidden = false
            }
            
        }
        nameOfTheYear?.image = #imageLiteral(resourceName: "nameOfTheYear")
        yeartext?.text = gPCodeToName(gpcode: groupCode)
        yeartext.textColor = UIColor(red: 1, green: 1, blue: 230/255, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    
    
    func changeStyle(label: UILabel) {
        label.layer.borderWidth = 2.0
        label.layer.cornerRadius = 5
        label.layer.borderColor = UIColor.gray.cgColor
        label.layer.masksToBounds = true
    }
    
    func newLessonGage(noOfQ:Int, label:UILabel) {
        label.text = "\(noOfQ)"
        label.textColor = UIColor.white
        let darkGray = UIColor(red: 105.0/255.0, green: 101.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        label.layer.backgroundColor = darkGray.cgColor
    }
    
    func oldLessonGage(noOfQ:Int, label:UILabel) {
        label.text = "\(noOfQ)"
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.gray.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadTags(code : Int? ,completionHandler: @escaping (CourseInfo?, Error?) -> ()) {
        if let  IDs: Int = code{
            
            Alamofire.request("http://www.kanoon.ir/Amoozesh/api/Document/GetCrsNbA?groupcode=\(IDs)")
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if let jArray = json.array{
                            for course in jArray{
                                if let cona = course["CrsName"].string{
                                    if let id = course["SumCrsId"].int{
                                        
                                        let doccount = course["DocumentCount"].int
                                        let SumCrsIdForQuiz = course["SumCrsIdForQuiz"].int
                                        let FromPage = course["FromPage"].int
                                        let ToPage = course["ToPage"].int
                                        
                                        let crsinf = CourseInfo()
                                        crsinf.courseName = cona
                                        crsinf.courseId = id
                                        crsinf.documentCount = doccount!
                                        crsinf.courseIdForQuiz = SumCrsIdForQuiz!
                                        crsinf.FromPage = FromPage!
                                        crsinf.ToPage = ToPage!
                                        
                                        completionHandler(crsinf , nil)
                                    }
                                }
                                
                            }
                            
                        }
                    case .failure(let error):
                        self.refreshButt.isHidden = false
                        completionHandler(nil, error)
                    }
            }
        }
    }
    
    
    
    func downloadExamDate(completionHandler: @escaping ([Int]?, Error?) -> ()){
        let urlStr = "http://www.kanoon.ir/Amoozesh/api/Document/GetCurrentTestDateNbA"
        Alamofire.request(urlStr).responseJSON{
            
            response in
            switch response.result {
                
            case .success(let value):
                
                let dateValue = value as! Int
                self.dateValue = "\(dateValue)"
                var timeseprated = [Int]()
                let mynum : Double = Double(dateValue)
                let mydub : Double = mynum/100
                let decimal11 = Int(mynum.truncatingRemainder(dividingBy: 100))
                let decimal1 = Int(mydub.truncatingRemainder(dividingBy: 100))
                timeseprated.append(decimal1)
                timeseprated.append(decimal11)
                completionHandler(timeseprated , nil)
                
            case .failure(let error):
                self.refreshButt.isHidden = false
                completionHandler(nil, error)
            }
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.courseinfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseNameTableViewCell
        
        let cellname = courseinfo[indexPath.row].courseName
        cell.courseName?.text = cellname
        cell.khatchin?.image = #imageLiteral(resourceName: "khatchin")
        let frompage = courseinfo[indexPath.row].FromPage
        let topage = courseinfo[indexPath.row].ToPage
        cell.coursePages?.text = "از صفحه \(frompage) تا صفحه \(topage)"
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourseId = courseinfo[indexPath.row].courseId
        selectedCourseIdForQuiz = courseinfo[indexPath.row].courseIdForQuiz
        performSegue(withIdentifier: "toTopics", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTopics"{
            let topics = segue.destination as! TopicsViewController
            topics.groupCode = self.groupCode
            topics.sumCrsID = selectedCourseId
            topics.sumCrsIDQ = selectedCourseIdForQuiz
            topics.dateValue = dateValue
        }
        
    }
    
    func fetchingDataFromCoreData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shomarande")
        do {
            loginCheck = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let loginChecks = loginCheck[0]
        
        groupCode = loginChecks.value(forKey: "shomare") as! Int
        
        
    }
    func gPCodeToName(gpcode : Int) -> String {
        let reshteCode = gpcode
        var reshteName = String()
        switch reshteCode {
        case 1:
            reshteName = "چهارم ریاضی"
        case 3:
            reshteName = "چهارم تجربی"
        case 5:
            reshteName = "چهارم انسانی"
        case 7:
            reshteName = "هنر"
        case 9:
            reshteName = "منحصرا زبان"
        case 21:
            reshteName = "سوم ریاضی"
        case 22:
            reshteName = "سوم تجربی"
        case 23:
            reshteName = "سوم انسانى"
        case 24:
            reshteName = "دهم ریاضی"
        case 25:
            reshteName = "دهم تجربی"
        case 26:
            reshteName = "دهم انسانی"
        case 27:
            reshteName = "نهم"
        case 31:
            reshteName = "هشتم"
        case 33:
            reshteName = "هفتم"
        case 35:
            reshteName = "ششم دبستان"
        case 41:
            reshteName = "پنجم دبستان"
        case 43:
            reshteName = "چهارم دبستان"
        case 45:
            reshteName = "سوم دبستان"
        case 46:
            reshteName = "دوم دبستان"
        case 47:
            reshteName = "اول دبستان"
        default:
            reshteName = ""
        }
        
        return reshteName
        
    }
    func turningDate(dateArray : [Int])-> String{
        let dateArray = dateArray
        var nameOfTheMonth = String()
        switch dateArray[0] {
        case 1:
            nameOfTheMonth = "\(dateArray[1]) فروردین "
        case 2:
            nameOfTheMonth = "\(dateArray[1]) اردیبهشت"
        case 3:
            nameOfTheMonth = "\(dateArray[1]) خرداد"
        case 4:
            nameOfTheMonth = "\(dateArray[1]) تیر"
        case 5:
            nameOfTheMonth = "\(dateArray[1]) مرداد"
        case 6:
            nameOfTheMonth = "\(dateArray[1]) شهریور"
        case 7:
            nameOfTheMonth = "\(dateArray[1]) مهر"
        case 8:
            nameOfTheMonth = "\(dateArray[1]) آبان"
        case 9:
            nameOfTheMonth = "\(dateArray[1]) آذر"
        case 10:
            nameOfTheMonth = "\(dateArray[1]) دی"
        case 11:
            nameOfTheMonth = "\(dateArray[1]) بهمن"
        case 12:
            nameOfTheMonth = "\(dateArray[1]) اسفند"
            
        default:
            nameOfTheMonth = "امتحانی وجود ندارد"
        }
        return nameOfTheMonth
        
    }
    func refreshAction(sender: UIButton!){
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            
            self.viewDidLoad()
        }
        
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape && flag{
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            print("Landscape")
        } else if UIDevice.current.orientation.isPortrait && !flag {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            print("Portrait")
        }
    }
    
}
