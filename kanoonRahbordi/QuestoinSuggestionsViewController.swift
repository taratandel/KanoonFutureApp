//
//  QuestoinSuggestionsViewController.swift
//  kanoonRahbordi
//
//  Created by Tara Tandel on 5/15/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

class SuggestionInfo {
    
    var isBookExist = Int()
    var cityName = String()
    var bookName = String()
    var bgName = String()
    var printYear = Int()
    var inspactorName = String()
    var tipName = String()
    var typesQuestiom = String()
    var stateName = String()
    var questionNumber = Int()
    var projectName = String()
    var pageNumber = Int()
    var printNumber = Int()
    var questionReason = String()
    
}

class QuestoinSuggestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dateValue = String()
    var groupCode = Int()
    var userCounter = Int()
    var suggestedQuestionsInfo = [SuggestionInfo]()
    
    @IBOutlet weak var suggestionsTable: UITableView!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var nameOfTheBookButt: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchingdatafromCoreData()
        getSuggestionsInfo(){
            response , error in
            if response != nil{
                self.suggestedQuestionsInfo.append(response!)
                self.nameOfTheBookButt.text = "از: " + self.suggestedQuestionsInfo[0].bookName
                
                self.suggestionsTable.reloadData()
            }
            else if error != nil {
                self.warning.text = "خطایی رخ داده دوباره امتحان کنید"
                self.nameOfTheBookButt?.text = "تلاش دوباره"
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameOftheBookAction(_ sender: Any) {
        if nameOfTheBookButt?.text == "تلاش دوباره" {
            self.viewDidLoad()
        }
        else if nameOfTheBookButt?.text == "فعال نشده است لطفا فردا امتحان کنید"{
            
        }
        else if nameOfTheBookButt?.text == ""
        {
            
        }
        else if nameOfTheBookButt?.text ==  "از: " + self.suggestedQuestionsInfo[0].bookName {
            warning.text = "بعدا فعال خواهد شد"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.warning?.text = ""
        }
    }
    
    
    func getSuggestionsInfo (completionHandler : @escaping (SuggestionInfo? , Error?)->()){
        let parameters: Parameters = ["counter" : userCounter, "dateValue" : dateValue, "groupCode" : groupCode]
        print (parameters)
        let url = "http://city.kanoon.ir/newsite/common/webservice/WSPublicApp.asmx/GetQuestionsuggestionForIos"
        Alamofire.request(url, method: .post, parameters : parameters/*, encoding: JSONEncoding.default*/).responseJSON{
            response in
            switch response.result{
            case .success(let value):
                let jsonRes = JSON(value)
                if jsonRes == -3 {
                    self.nameOfTheBookButt.text = "فعال نشده است لطفا فردا امتحان کنید"
                    completionHandler( nil , nil )
                }
                    
                else if let jArray = jsonRes.array{
                    for items in jArray{
                        let questions = SuggestionInfo()
                        questions.bgName = items["BgName"].string!
                        questions.bookName = items["BookName"].string!
                        questions.cityName = items["CityName"].string!
                        questions.inspactorName = items["InspactorName"].string!
                        questions.isBookExist = items["IsBookExist"].int!
                        questions.pageNumber = items["PageNumber"].int!
                        questions.printNumber = items["PrintNumber"].int!
                        questions.printYear = items["PrintYear"].int!
                        questions.projectName = items["ProjectName"].string!
                        questions.questionNumber = items["QuestionNumber"].int!
                        questions.questionReason = items["QuestionReason"].string!
                        questions.stateName = items["StateName"].string!
                        questions.tipName = items["TipName"].string!
                        questions.typesQuestiom = items["typesQuestiom"].string!
                        completionHandler(questions, nil)
                        
                    }
                    
                }
            case .failure(let error):
                print("fail")
                completionHandler(nil, error)
            }
        }
    }
    
    func fetchingdatafromCoreData(){
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
            let std = try managedContext.fetch(fechtRequest)
            let isKanooni = std[0].value(forKey: "isKanooni") as! Bool
            if isKanooni{
                userCounter = std[0].value(forKey: "id") as! Int
            }
            
        }
        catch let error as NSError {
            //if not shows the error
            print("Could not fetch. \(error), \(error.userInfo)")
            warning.text = "خطایی رخ داده لطفا برنامه را بسته و دوباره باز کنید"
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedQuestionsInfo.count - 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestion", for: indexPath)
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.text = "\(indexPath.row + 6)" + "- " + "سوال: " + " \(suggestedQuestionsInfo[indexPath.row].questionNumber) " + " - صفحه : " + " \(suggestedQuestionsInfo[indexPath.row].pageNumber) "
        if suggestedQuestionsInfo.count > 5{
            cell.detailTextLabel?.textAlignment = .right
            cell.detailTextLabel?.text = "\(indexPath.row + 5)" + "- " + "سوال: " + " \(suggestedQuestionsInfo[indexPath.row + 5].questionNumber) " + " - صفحه : " + " \(suggestedQuestionsInfo[indexPath.row + 5].pageNumber) "
        }
        return cell
    }
    
}
