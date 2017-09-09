//
//  TopicsViewController.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Tir/21 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TopicInfo {
    public var SumSbjId = Int()
    public var SbjName = String()
    public var OrderId = Int()
    public var SumSbjIdForQuiz = Int()
}

class TopicCell: UITableViewCell {
    
    @IBOutlet weak var cellLbl: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
}

class TopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topicsTable: UITableView!
    @IBOutlet weak var triangle: UIImageView!
    
    var groupCode : Int = 0
    var sumCrsID : Int = 0
    var sumCrsIDQ : Int = 0
    var topicsArr = [TopicInfo]()
    var indexpath = Int()
    var dateValue = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationItem.rightBarButtonItem = editButtonItem
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        triangle.image = #imageLiteral(resourceName: "Image")
        self.topicsTable.separatorStyle = .none
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        downloadTags(GCode: groupCode, SCID: sumCrsID){
            topicInfo,  error in
            
            if topicInfo != nil {
                self.topicsArr.append(topicInfo!)
                self.topicsTable.reloadData()
            }
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadTags(GCode : Int?, SCID : Int ,completionHandler: @escaping (TopicInfo?, Error?) -> ()) {
        if let  IDs: Int = GCode{
            
            Alamofire.request("http://www.kanoon.ir/Amoozesh/api/Document/GetSumSbjNbA?groupCode=\(IDs)&sumcrsid=\(SCID)")
                .responseJSON { response in
                    switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            if let jArray = json.array{
                                for topic in jArray{
                                    if topic["SumSbjId"] != 0 {
                                        let SumSbjId = topic["SumSbjId"].int
                                        let SbjName = topic["SbjName"].string
                                        let OrderId = topic["OrderId"].int
                                        let SumSbjIdForQuiz = topic["SumSbjIdForQuiz"].int
                                        let topicInfo = TopicInfo()
                                        topicInfo.SumSbjId = SumSbjId!
                                        topicInfo.SbjName = SbjName!
                                        topicInfo.OrderId = OrderId!
                                        topicInfo.SumSbjIdForQuiz = SumSbjIdForQuiz!
                                        completionHandler(topicInfo, nil)
                                    }
                                    
                                }
                            }
                        case .failure(let error):
                            completionHandler(nil, error)
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicsArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        
        cell.cellLbl.text=topicsArr[indexPath.row].SbjName
        cell.cellLbl.textColor = UIColor(red: 1, green: 1, blue: 230/255, alpha: 1)
        cell.cellImg.image = #imageLiteral(resourceName: "topicCursor")
        
        let R = 229
        let G = 204
        
        var nextR = CGFloat(Double(Float(R - indexPath.row*25)/Float(255)))
        var nextG = CGFloat(Double(Float(G - indexPath.row*50)/Float(255)))
        if nextR<0{
            nextR=0
        }
        if nextG<0{
            nextG=0
        }
        cell.contentView.backgroundColor = UIColor(red: nextR, green: nextG, blue: 1, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexpath = indexPath.row
        performSegue(withIdentifier: "toTabs", sender: self)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTabs"{
            
            let tabView = segue.destination as! UITabBarController
            
            let videoPage = tabView.viewControllers?[0] as! EducationalVideos
            videoPage.sumcrsid = sumCrsID
            videoPage.sumsbjid = topicsArr[indexpath].SumSbjId
            videoPage.groupCode = groupCode
            videoPage.subName = topicsArr[indexpath].SbjName

            
            let summaryPage = tabView.viewControllers?[1] as! EducationalSummaries
            summaryPage.sumcrsid = sumCrsID
            summaryPage.sumsbjid = topicsArr[indexpath].SumSbjId
            summaryPage.subName = topicsArr[indexpath].SbjName
            summaryPage.groupCode = groupCode
            
            let quizPage = tabView.viewControllers?[2] as! QuizViewController
            quizPage.groupCode = groupCode
            quizPage.SumCrsId = sumCrsID
            quizPage.SumSbjId = topicsArr[indexpath].SumSbjId
            
            let suggestionPage = tabView.viewControllers?[3] as! QuestoinSuggestionsViewController
            suggestionPage.groupCode = groupCode
            suggestionPage.dateValue = dateValue
        }
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
