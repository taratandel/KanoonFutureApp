//
//  QuizViewController.swift
//  kanoonRahbordi
//
//  Created by Tara Tandel on 5/2/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON
import PINRemoteImage


class Quiz {
    var Id = Int()
    var QuestionImageAddress = String()
    var QuestionId = Int()
    var QuestionAnswerImage = String()
    var AnswerKey = Int()
    var UserAsnwer = Int()
    var UserCounter = Int()
    var FinishDateTime : Bool? = nil
    var answered : Bool? = false
}


class QuizViewController: UIViewController {
    
    var topic = String()
    
    var userCounter = Int()
    var groupCode = Int()
    
    var SumCrsId = Int()
    
    var SumSbjId = Int()
    var SumSbjIdForQuiz = Int()
    var SumCrsIdForQuiz = Int()
    
    var quizNum = Int()
    
    var quizArr = [Quiz]()
    
    
    
    @IBOutlet weak var warning: UILabel!
    
    @IBOutlet weak var questionImg: UIImageView!
    
    @IBOutlet weak var option1: UIButton!
    
    @IBOutlet weak var option2: UIButton!
    
    @IBOutlet weak var option3: UIButton!
    
    @IBOutlet weak var option4: UIButton!
    
    @IBOutlet weak var nextQ: UIButton!
    
    @IBOutlet weak var previousQ: UIButton!
    
    @IBOutlet weak var showAnswer: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        makethemRound()
        nextQ.setImage(#imageLiteral(resourceName: "next"), for: .normal)
        previousQ.setImage(#imageLiteral(resourceName: "previous"), for: .normal)
        
        self.fetchingdatafromCoreData()
        
        self.quizNum = 0
        
        self.warning.text = "سوال \(self.quizNum+1)"
        
        self.showAnswer.isHidden = true
        
        self.GetSumSbjIdForQuiz(groupCode: self.groupCode, sumcrsid: self.SumCrsId, sbj: self.SumSbjId){
            sbj, error in
            
            if sbj != 0{
                self.SumSbjIdForQuiz = sbj
                self.GetSumCrsIdForQuiz(groupcode: self.groupCode, crs: self.SumCrsId){
                    qcrs, error in
                    
                    if qcrs != 0{
                        self.SumCrsIdForQuiz = qcrs
                        
                        self.validForQuiz(usercounter: self.userCounter, groupCode: self.groupCode, Qsumcrsid: self.SumCrsIdForQuiz, QsumSbjId: self.SumSbjIdForQuiz){
                            
                            yek, error in
                            
                            if yek == 1 {
                                
                                self.getQuiz(usercounter: self.userCounter, groupCode: self.groupCode, Qsumcrsid: self.SumCrsIdForQuiz, QsumSbjId: self.SumSbjIdForQuiz){
                                    qa, er in
                                    
                                    if qa.count != 0{
                                        self.quizArr = qa
                                        self.setImg(imgUrl: self.quizArr[self.quizNum].QuestionImageAddress, img: self.questionImg)
                                        
                                    }
                                    else {
                                        self.warning.text = "دوباره تلاش کنید"
                                    }
                                }
                                
                            }
                            else {
                                self.warning.text = "دوباره تلاش کنید"
                            }
                        }
                    }
                }
            }
            else{
                self.warning.text = "دوباره تلاش کنید"
            }
        }
        
        
        
        
        
        
        print(quizArr.count)
        // Do any additional setup after loading the view.
    }
    
    func validForQuiz(usercounter: Int , groupCode: Int, Qsumcrsid: Int, QsumSbjId: Int, completionHandler : @escaping (Int, Error?) -> () )  {
        
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/StartQuiz?usercounter=\(usercounter)&groupCode=\(groupCode)&sumcrsid=\(Qsumcrsid)&sumSbjId=\(QsumSbjId)&sumObjId=0"
        
        Alamofire.request(url).responseJSON{ response in
            
            if NetworkReachabilityManager()!.isReachable{
                switch response.result{
                case .success(let value):
                    if let result: Int = value as? Int{
                        completionHandler(result, nil)
                    }
                case .failure(let error):
                    completionHandler(0, error)
                }
            }
                
            else{
                self.warning.text = "اینترنت خود را بررسی کنید"
                self.warning.textColor = UIColor.blue
                
            }
        }
    }
    
    func GetSumSbjIdForQuiz (groupCode : Int, sumcrsid : Int, sbj : Int,
                             completionHandler : @escaping(Int, Error?) -> ()) {
        
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/GetSumSbjNbA?groupCode=\(groupCode)&sumcrsid=\(sumcrsid)"
        
        Alamofire.request(url).responseJSON{ response in
            
            if NetworkReachabilityManager()!.isReachable{
                switch response.result{
                case .success(let value):
                    let j = JSON(value)
                    if let jArr = j.array{
                        
                        for item in jArr{
                            if(item["SumSbjId"].int == sbj){
                                completionHandler(item["SumSbjIdForQuiz"].int! , nil)
                                
                            }
                        }
                    }
                    if let result: NSDictionary = value as? NSDictionary{
                        completionHandler( result["SumSbjIdForQuiz"] as! Int, nil)
                    }
                case .failure(let error):
                    completionHandler(0, error)
                }
            }
                
            else{
                self.warning.text = "اینترنت خود را بررسی کنید"
                self.warning.textColor = UIColor.blue
                
            }
        }
    }
    
    func GetSumCrsIdForQuiz(groupcode : Int, crs : Int, complitionHandler : @escaping(Int, Error?) -> ()) {
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/GetCrsNbA?groupcode=\(groupcode)"
        Alamofire.request(url).responseJSON{ response in
            switch response.result{
            case .success(let value):
                let j = JSON(value)
                if let jArr = j.array{
                    for item in jArr{
                        if (item["SumCrsId"].int) == crs{
                            complitionHandler(item["SumCrsIdForQuiz"].int!, nil)
                        }
                    }
                }
            case .failure(let error):
                complitionHandler(0, error)
            }
            
        }
    }
    
    func getQuiz(usercounter: Int , groupCode: Int, Qsumcrsid: Int, QsumSbjId: Int, completionHandler : @escaping([Quiz], Error?) -> () ) {
        
        var QA = [Quiz]()
        
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/GetQuiz?usercounter=\(usercounter)&groupCode=\(groupCode)&sumcrsid=\(Qsumcrsid)&sumSbjId=\(QsumSbjId)&sumObjId=0"
        Alamofire.request(url).responseJSON{ response in
            
            if NetworkReachabilityManager()!.isReachable{
                switch response.result{
                case .success(let value):
                    let j = JSON(value)
                    if let jArr = j.array{
                        for item in jArr{
                            
                            let quiz = Quiz()
                            
                            quiz.Id = item["Id"].int!
                            quiz.QuestionImageAddress = item["QuestionImageAddress"].string!
                            quiz.QuestionId = item["QuestionId"].int!
                            quiz.QuestionAnswerImage = item["QuestionAnswerImage"].string!
                            quiz.AnswerKey = item["AnswerKey"].int!
                            quiz.UserAsnwer = item["UserAsnwer"].int!
                            quiz.UserCounter = item["UserCounter"].int!
                            quiz.FinishDateTime = item["FinishDateTime"].bool
                            
                            QA.append(quiz)
                            
                        }
                        completionHandler(QA, nil)
                    }
                case .failure(let error):
                    print("err")
                    completionHandler([], error)
                }
            }
                
            else{
                self.warning.text = "اینترنت خود را بررسی کنید"
                self.warning.textColor = UIColor.blue
                
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
            userCounter = std[0].value(forKey: "id") as! Int
            
        }
        catch let error as NSError {
            //if not shows the error
            print("Could not fetch. \(error), \(error.userInfo)")
            warning.text = "خطایی رخ داده لطفا برنامه را بسته و دوباره باز کنید"
        }
        
    }
    
    func setImg(imgUrl : String, img: UIImageView) {
        img.pin_setImage(from: URL(string: imgUrl), completion: { (result) in
        })
    }
    
    
    @IBAction func option1Choosed(_ sender: Any) {
        self.option1.isEnabled = false
        self.option2.isEnabled = false
        self.option3.isEnabled = false
        self.option4.isEnabled = false
        
        quizArr[quizNum].answered = true
        quizArr[quizNum].UserAsnwer = 1
        
        self.answerCheck()
        
        if (self.checkFinish()){
            self.showAnswer.isHidden = false
        }
        
    }
    
    @IBAction func option2Choosed(_ sender: Any) {
        self.option1.isEnabled = false
        self.option2.isEnabled = false
        self.option3.isEnabled = false
        self.option4.isEnabled = false
        
        quizArr[quizNum].answered = true
        quizArr[quizNum].UserAsnwer = 2
        
        self.answerCheck()
        
        if (self.checkFinish()){
            self.showAnswer.isHidden = false
        }
    }
    
    @IBAction func option3Choosed(_ sender: Any) {
        self.option1.isEnabled = false
        self.option2.isEnabled = false
        self.option3.isEnabled = false
        self.option4.isEnabled = false
        
        quizArr[quizNum].answered = true
        quizArr[quizNum].UserAsnwer = 3
        
        self.answerCheck()
        
        if (self.checkFinish()){
            self.showAnswer.isHidden = false
        }
    }
    
    @IBAction func option4Choosed(_ sender: Any) {
        self.option1.isEnabled = false
        self.option2.isEnabled = false
        self.option3.isEnabled = false
        self.option4.isEnabled = false
        
        quizArr[quizNum].answered = true
        quizArr[quizNum].UserAsnwer = 4
        
        self.answerCheck()
        
        if (self.checkFinish()){
            self.showAnswer.isHidden = false
        }
    }
    
    
    
    func answerCheck() {
        
        self.option1.backgroundColor = UIColor.white
        self.option2.backgroundColor = UIColor.white
        self.option3.backgroundColor = UIColor.white
        self.option4.backgroundColor = UIColor.white
        
        if quizArr[quizNum].answered == false
        {
            self.option1.isEnabled = true
            self.option2.isEnabled = true
            self.option3.isEnabled = true
            self.option4.isEnabled = true
        }else{
            if self.quizArr[quizNum].AnswerKey != self.quizArr[quizNum].UserAsnwer {
                self.showIncorrect()
            }
            self.showCorrect()
        }
        
        
    }
    
    func showCorrect() {
        switch quizArr[quizNum].AnswerKey {
        case 1:
            self.option1.backgroundColor = UIColor.green
        case 2:
            self.option2.backgroundColor = UIColor.green
        case 3:
            self.option3.backgroundColor = UIColor.green
        case 4:
            self.option4.backgroundColor = UIColor.green
        default: break
            
        }
    }
    
    func showIncorrect() {
        switch quizArr[quizNum].UserAsnwer {
        case 1:
            self.option1.backgroundColor = UIColor.red
        case 2:
            self.option2.backgroundColor = UIColor.red
        case 3:
            self.option3.backgroundColor = UIColor.red
        case 4:
            self.option4.backgroundColor = UIColor.red
        default: break
            
        }
    }
    
    @IBAction func nextQuestion(_ sender: Any) {
        
        if self.quizNum<9 {
            self.quizNum += 1
            self.setImg(imgUrl: self.quizArr[self.quizNum].QuestionImageAddress, img: self.questionImg)
            self.warning.text = "سوال \(self.quizNum+1)"
            self.answerCheck()
        } else {
            self.warning.text = "سوالات تمام شد"
        }
        
    }
    
    @IBAction func previousQuestion(_ sender: Any) {
        if self.quizNum>0 {
            self.quizNum -= 1
            self.setImg(imgUrl: self.quizArr[self.quizNum].QuestionImageAddress, img: self.questionImg)
            self.warning.text = "سوال \(self.quizNum+1)"
            self.answerCheck()
        } else {
            self.warning.text = "سوال اول است"
        }
    }
    
    func checkFinish() -> Bool{
        
        var check : Bool = true
        for item in quizArr {
            if item.answered == false{
                check = false
            }
        }
        return check
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var arr = [String]()
        if segue.identifier == "showAns"{
            for item in self.quizArr {
                arr.append(item.QuestionAnswerImage)
            }
            let ansPage = segue.destination as! AnswersViewController
            ansPage.answersUrl = arr
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makethemRound(){
        option1.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        option2.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        option3.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        option4.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
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
