//
//  EducationalSummaries.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Tir/13 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PINRemoteImage
import AVKit
import AVFoundation
import CoreData

class SummeriesCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var tickImg: UIImageView!
    @IBOutlet weak var nameOfTheTeacher: UILabel!
    @IBOutlet weak var pictureOfThePdf: UIImageView!
    
    @IBOutlet weak var tikImg: UIImageView!
}
class SummaryCollectionHeader: UICollectionReusableView{
    
    @IBOutlet weak var summHeader: UILabel!
    
    
}
class EducationalSummaries: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var summArr = [SummaryInfo]()
    var sumcrsid = Int()
    var sumsbjid = Int()
    var groupCode = Int()
    var subName = String()
    var currentIndexPath = Int()
    var cellIsChecked = [Int : Bool]()
    var summCellIsChecked = [Int : CellDidChange]()
    var summCellDidChange = CellDidChange()
    var userinf: [NSManagedObject] = []
    var id: Int = 0
    
    
    @IBOutlet weak var fav: UIButton!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var downButt: UIButton!
    @IBOutlet weak var summeryCollectionView: UICollectionView!
    @IBOutlet weak var topic: UILabel!
    

    @IBAction func showFavButt(_ sender: Any) {
        
        performSegue(withIdentifier: "showSummFav", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let leftButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.someFunc))
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let urlstr = "http://www.kanoon.ir/Amoozesh/api/Document/GetLessonSummaryNbA?groupcode=\(groupCode)&sumcrsid=\(sumcrsid)&sumsbjid=\(sumsbjid)"
        
        topic.text = subName
        downloadSummary(url: urlstr){
            summariesInfo , error in
            if summariesInfo != nil {
                self.summArr.append(summariesInfo!)
                self.summeryCollectionView.reloadData()
            }
            else {
                print("no net")
                // put a lable to warn them
            }
        }
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        fav.isHidden = true
        play.isHidden = true
        
        play.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fav.addTopBorderWithColor(color: .gray, width: 1.0)
        downButt.addTopBorderWithColor(color: .gray, width: 1.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refresh(_ sender: Any) {
        
        let cellBackToNormal = CellDidChange()
        summCellDidChange = cellBackToNormal
        summCellIsChecked = [ : ]
        summArr.removeAll()
        self.viewDidLoad()
    }
    
    @IBAction func playButt(_ sender: Any) {
        
        summCellDidChange.playbut = true
        if let sym : Bool = (summCellIsChecked[currentIndexPath]?.favbutt){
            if sym{
                summCellDidChange.favbutt = true
                summCellIsChecked[currentIndexPath] = summCellDidChange
            }
        }
        else {
            summCellIsChecked[currentIndexPath] = summCellDidChange
            
        }
        insertsumsee(url : "http://www.kanoon.ir/Amoozesh/api/Document/InsertVisitLessonSummaryNbA?Rid=\(summArr[currentIndexPath].Rid)"){
            response in
            if response != nil{
                print(response)
            }
        }
        performSegue(withIdentifier: "pdfView", sender: self)
        summeryCollectionView.reloadData()
        let cellBackToNormal = CellDidChange()
        summCellDidChange = cellBackToNormal
        
    }
    
    @IBAction func favButt(_ sender: Any) {
        
        addToFavorites(documentId: summArr[currentIndexPath].Rid, sumobjid: summArr[currentIndexPath].SumObjId){
            response , error in
            
            if response != nil && response == 1 {
                self.summCellDidChange.favbutt = true
                if let sym : Bool = (self.summCellIsChecked[self.currentIndexPath]?.playbut){
                    if sym{
                        self.summCellDidChange.playbut = true
                        self.summCellIsChecked[self.currentIndexPath] = self.summCellDidChange
                    }
                }
                else {
                    self.summCellIsChecked[self.currentIndexPath] = self.summCellDidChange
                    
                }
                self.summeryCollectionView.reloadData()
                let cellBackToNormal = CellDidChange()
                self.summCellDidChange = cellBackToNormal
                
                
                
            }
            
        }
        
    }
    
    
    func downloadSummary (url : String? , completionHandler : @escaping (SummaryInfo? , Error?) -> ()){
        if let urlstr = url{
            Alamofire.request(urlstr).responseJSON{
                response in
                switch response.result{
                case . success(let value):
                    let jsonresponse = JSON(value)
                    if let jsonArray = jsonresponse.array{
                        for summaries in jsonArray{
                            var sumInfo = SummaryInfo()
                            sumInfo.LessonSummaryTitle = summaries["LessonSummaryTitle"].string!
                            sumInfo.ProfileId = summaries["ProfileId"].int!
                            sumInfo.Rid = summaries["Rid"].int!
                            sumInfo.SumObjId = summaries["SumObjId"].int!
                            sumInfo.TeacherName = summaries["TeacherName"].string!
                            completionHandler(sumInfo , nil)
                        }
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "summCollectionHeader", for: indexPath) as! SummaryCollectionHeader
            
            headerView.summHeader.text = "خلاصه درس ها"
            headerView.summHeader.textColor = .white
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return summArr.count - 7
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath) as! SummeriesCollectionViewCell
        
        cell.nameOfTheTeacher?.text = summArr[indexPath.row].LessonSummaryTitle
        print(indexPath.row, summArr[indexPath.row].LessonSummaryTitle)
        cell.tikImg?.image = #imageLiteral(resourceName: "blueArrow")
        cell.pictureOfThePdf?.image = #imageLiteral(resourceName: "pdf")
        if let isTrue : CellDidChange = summCellIsChecked[indexPath.row]{
            if isTrue.favbutt && isTrue.playbut{
                cell.tikImg.image = #imageLiteral(resourceName: "fav")
                cell.tikImg.tintColor = .yellow
                cell.tickImg.isHidden = false
                cell.tickImg.image = #imageLiteral(resourceName: "checked")
                cell.tickImg.alpha = 0.5
            }
            else if isTrue.playbut {
                cell.tickImg.isHidden = false
                cell.tickImg.image = #imageLiteral(resourceName: "checked")
                cell.tickImg.alpha = 0.5
                cell.tikImg.image = #imageLiteral(resourceName: "blueArrow")
                
                
            }
                
            else if isTrue.favbutt{
                cell.tikImg.image = #imageLiteral(resourceName: "fav")
                cell.tikImg.tintColor = .yellow
                cell.tickImg.isHidden = true
                
                
            }
            
            
            
        }
        else {
            cell.tikImg.image = #imageLiteral(resourceName: "blueArrow")
            cell.tickImg.isHidden = true
        }
        cell.fullyRound(diameter: 10, borderColor: .yellow, borderWidth: 1)
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = summeryCollectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: (widthPerItem ), height: (widthPerItem ))
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if summArr.count > 0 {
        self.play.isHidden = false
        self.fav.isHidden = false
        
        }
        currentIndexPath=indexPath.row
        let cell1 = collectionView.cellForItem(at: indexPath)
        let cell : SummeriesCollectionViewCell = cell1 as! SummeriesCollectionViewCell
        cell.fullyRound(diameter: 10, borderColor: UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1), borderWidth: 3)
        currentIndexPath = indexPath.row
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell1 = collectionView.cellForItem(at: indexPath)
        let cell : SummeriesCollectionViewCell = cell1 as! SummeriesCollectionViewCell
        cell.fullyRound(diameter: 10, borderColor: .yellow, borderWidth: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pdfView"{
            let pdfView = segue.destination as! PDFViewController
            pdfView.url = "http://www.kanoon.ir/Amoozesh/Films/Download?id=\(summArr[currentIndexPath].Rid)&type=1"
        }
            if segue.identifier == "showSummFav"
            {
                let showfave = segue.destination as! SummaryFavTableViewController
                showfave.sumcrsid = self.sumcrsid
                showfave.sumsbjid = self.sumsbjid
                showfave.id = self.id
                showfave.groupCode = self.groupCode
            }
        

    }
    
    func addToFavorites( documentId: Int, sumobjid : Int, completionHandler: @escaping (Int? , Error?) -> () ){
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/InsertFavoriteNbA?groupcode=\(self.groupCode)&sumcrsid=\(self.sumcrsid)&sumsbjid=\(self.sumsbjid)&userId=\(self.id)&dataid=\(documentId)&type=2&sumobjid=\(sumobjid)"
        Alamofire.request(url).responseString {
            
            response in
            switch response.result{
            case .success (let value):
                let result : Int = Int(value)!
                completionHandler(result, nil)
            case .failure (let error):
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
            userinf = try managedContext.fetch(fechtRequest)
            id = userinf[0].value(forKey: "shomare") as! Int
        }
        catch let error as NSError {
            //if not shows the error
            print("Could not fetch. \(error), \(error.userInfo)")
            //Warning?.text = "خطایی رخ داده لطفا برنامه را بسته و دوباره باز کنید"
        }
        
    }
    func favact(){
        print("hi")
    }
    @objc func someFunc() {
        
        print("It Works")
    }
    func insertsumsee(url : String, completionHandler : @escaping (String? , Error?)->()){
        Alamofire.request(url).responseString{
            response in
            switch response.result{
            case .success(let value):
                completionHandler(value as! String, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
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
