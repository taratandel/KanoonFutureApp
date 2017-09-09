//
//  EducationalVideos.swift
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

class CellDidChange{
    var playbut = Bool()
    var favbutt = Bool()
}
class MoviesCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var tickImg: UIImageView!
    @IBOutlet weak var tikImage: UIImageView!
    @IBOutlet weak var NameOfTheLabes: UILabel!
    @IBOutlet weak var pictureOfTheTeacher: UIImageView!
    @IBOutlet weak var comment: UIButton!
    
}
class CollectionHeader: UICollectionReusableView{
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var filmBackImage: UIImageView!
    
}
class EducationalVideos: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var nameOfTheTopic: UILabel!
    @IBOutlet weak var playButt: UIButton!
    @IBOutlet weak var favButt: UIButton!
    @IBOutlet weak var downButt: UIButton!
    @IBOutlet weak var favs: UIButton!
    
    @IBOutlet weak var moviesCollection: UICollectionView!
    @IBOutlet weak var topicMosalas: UIImageView!
    
    var moviesInfo = [MoviesDara]()
    var sumcrsid = Int()
    var sumsbjid = Int()
    var groupCode = Int()
    var subName = String()
    var pageindex : Int = 1
    var currentIndexPath = Int()
    var cellIsChecked = [Int : CellDidChange]()
    var userinf: [NSManagedObject] = []
    var id: Int = 0
    var cellDidChange = CellDidChange()
    
    @IBAction func showMovieFavButton(_ sender: Any) {
        
        performSegue(withIdentifier: "movieFaves", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        favButt.addTopBorderWithColor(color: .gray, width: 1.0)
        downButt.addTopBorderWithColor(color: .gray, width: 1.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        settingInitials()
        
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/GetVideoNbA?groupcode=\(groupCode)&sumcrsid=\(sumcrsid)&sumsbjid=\(sumsbjid)&pageindex=\(pageindex)&pagesize=3"
        
        downloadfilms(url: url){
            moviesinfo , error in
            if moviesinfo != nil {
                self.moviesInfo.append(moviesinfo!)
                self.moviesCollection.reloadData()
            }
                
            else {
                self.downButt.titleLabel?.text = "تلاش مجدد"
            }
        }
        
        
        
        fetchingdatafromCoreData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func settingInitials(){
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.automaticallyAdjustsScrollViewInsets = false;
        
        nameOfTheTopic?.text = subName
        
        favButt.isHidden = true
        playButt.isHidden = true
        
        playButt.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        topicMosalas.image = #imageLiteral(resourceName: "topicCursor")
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath) as! CollectionHeader
            
            headerView.headerLabel.text = "فیلم های آموزشی"
            headerView.headerLabel.textColor = .white
            //            headerView.filmBackImage.image = #imageLiteral(resourceName: "filmback")
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        if downButt.titleLabel?.text == "تلاش مجدد"
        {
            self.viewDidLoad()
        }
            
        else if downButt.titleLabel?.text == "مشاهده سایر فیلم ها"
        {
            let cellBackToNormal = CellDidChange()
            cellDidChange = cellBackToNormal
            cellIsChecked = [ : ]
            moviesInfo=[]
            pageindex += 1
            self.viewDidLoad()
        }
    }
    
    @IBAction func playButt(_ sender: Any) {
        cellDidChange.playbut = true
        if let sym : Bool = (cellIsChecked[currentIndexPath]?.favbutt){
            if sym{
                cellDidChange.favbutt = true
                cellIsChecked[currentIndexPath] = cellDidChange
            }
        }
        else {
            cellIsChecked[currentIndexPath] = cellDidChange
            
        }
        
        let link = moviesInfo[currentIndexPath].M3u8Address
        guard let url = URL(string: link) else {
            return
        }
        let player = AVPlayer(url: url)
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            player.play()
        }
        insertmoviesee(url: "http://www.kanoon.ir/Amoozesh/api/Document/InsertVisitNbA?userCounter=\(id)&DocumentId=\(moviesInfo[currentIndexPath].DocumentId)"){
            response in
            if response != nil {
                print("success")
            }
        }
        self.moviesCollection.reloadData()
        let cellBackToNormal = CellDidChange()
        cellDidChange = cellBackToNormal
        
    }
    
    @IBAction func favButt(_ sender: Any) {
        
        addToFavorites(documentId: moviesInfo[currentIndexPath].DocumentId, sumobjid: moviesInfo[currentIndexPath].SumObjId){
            response , error in
            
            if response != nil && response == 1 {
                self.cellDidChange.favbutt = true
                if let sym : Bool = (self.cellIsChecked[self.currentIndexPath]?.playbut){
                    if sym{
                        self.cellDidChange.playbut = true
                        self.cellIsChecked[self.currentIndexPath] = self.cellDidChange
                    }
                }
                else {
                    self.cellIsChecked[self.currentIndexPath] = self.cellDidChange
                    
                }
                self.moviesCollection.reloadData()
                let cellBackToNormal = CellDidChange()
                self.cellDidChange = cellBackToNormal
                
                
                
            }
            
        }
        
    }
    
    func downloadfilms (url : String? , completionHandler : @escaping (MoviesDara? , Error?) -> ()){
        if let urlstr = url{
            Alamofire.request(urlstr).responseJSON{
                response in
                switch response.result{
                case . success(let value):
                    let jsonresponse = JSON(value)
                    if let jsonArray = jsonresponse.array{
                        for movies in jsonArray{
                            let moviesinfo = MoviesDara()
                            moviesinfo.DocumentId = movies["DocumentId"].int!
                            moviesinfo.FileTitle = movies["FileTitle"].string!
                            moviesinfo.M3u8Address = movies["M3u8Address"].string!
                            moviesinfo.TeacherId = movies["TeacherId"].int!
                            moviesinfo.TeacherName = movies["TeacherName"].string!
                            moviesinfo.TeacherPicture = movies["TeacherPicture"].string!
                            moviesinfo.SumObjId = movies["SumObjId"].int!
                            moviesinfo.Comment = movies["Comment"].dictionaryObject
                            
                            completionHandler(moviesinfo , nil)
                        }
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if moviesInfo.count > 3 {
            return 3
        }
        else {
            return moviesInfo.count
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vidoesCell", for: indexPath) as! MoviesCollectionViewCell
        
        cell.NameOfTheLabes?.text = moviesInfo[indexPath.row].TeacherName
        cell.tikImage?.image = #imageLiteral(resourceName: "blueArrow")
        if let isTrue : CellDidChange = cellIsChecked[indexPath.row]{
            if isTrue.favbutt && isTrue.playbut{
                cell.tikImage.image = #imageLiteral(resourceName: "fav")
                cell.tikImage.tintColor = .yellow
                cell.tickImg.isHidden = false
                cell.tickImg.image = #imageLiteral(resourceName: "checked")
                cell.tickImg.alpha = 0.5
            }
            else if isTrue.playbut {
                cell.tickImg.isHidden = false
                cell.tickImg.image = #imageLiteral(resourceName: "checked")
                cell.tickImg.alpha = 0.5
                cell.tikImage.image = #imageLiteral(resourceName: "blueArrow")
                
                
            }
                
            else if isTrue.favbutt{
                cell.tikImage.image = #imageLiteral(resourceName: "fav")
                cell.tikImage.tintColor = .yellow
                cell.tickImg.isHidden = true
                
                
            }
            
            
            
        }
        else {
            cell.tikImage.image = #imageLiteral(resourceName: "blueArrow")
            cell.tickImg.isHidden = true
        }
        
        let imageUrl = moviesInfo[indexPath.row].TeacherPicture
        
        cell.pictureOfTheTeacher?.pin_setImage(from: URL(string: imageUrl), completion: { (result) in
        })
        cell.pictureOfTheTeacher.contentMode = .scaleAspectFit
        cell.fullyRound(diameter: 10, borderColor: .yellow, borderWidth: 1)
        cell.comment.tag = indexPath.row
        cell.comment.addTarget(self, action: #selector(editButtonTapped), for: UIControlEvents.touchUpInside)
        //        cell.tickImg.isHidden=true
        
        return cell
    }
    func editButtonTapped (sender: UIButton){
        var commentStr = String()
        var stuStr = String()
        var uStr = String()
        if moviesInfo[sender.tag].Comment != nil {
            commentStr = moviesInfo[sender.tag].Comment?["Comment"] as! String
            stuStr = moviesInfo[sender.tag].Comment?["StudentFullName"] as! String
            uStr = moviesInfo[sender.tag].Comment?["UnivercityName"] as! String
            
        }        else {
            commentStr = "در حال حاضر کامنتی وجود ندارد"
            stuStr = ""
            uStr = ""
        }
        let alert = UIAlertController(title: " \(stuStr) " + "( \(uStr) )", message: "\(commentStr)",preferredStyle: .alert)
        let cancelacrion = UIAlertAction(title: "بازگشت", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancelacrion)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = moviesCollection.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: (widthPerItem), height: (widthPerItem ))
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
        if moviesInfo.count > 0 {
            self.playButt.isHidden = false
            self.favButt.isHidden = false
        }
        
        currentIndexPath=indexPath.row
        let cell1 = collectionView.cellForItem(at: indexPath)
        let cell : MoviesCollectionViewCell = cell1 as! MoviesCollectionViewCell
        
        cell.fullyRound(diameter: 10, borderColor: UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1), borderWidth: 3)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell1 = collectionView.cellForItem(at: indexPath)
        let cell : MoviesCollectionViewCell = cell1 as! MoviesCollectionViewCell
        cell.fullyRound(diameter: 10, borderColor: .yellow, borderWidth: 1)
    }
    func addToFavorites( documentId: Int, sumobjid : Int, completionHandler: @escaping (Int? , Error?) -> () ){
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/InsertFavoriteNbA?groupcode=\(self.groupCode)&sumcrsid=\(self.sumcrsid)&sumsbjid=\(self.sumsbjid)&userId=\(self.id)&dataid=\(documentId)&type=1&sumobjid=\(sumobjid)"
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieFaves"
        {
            let showfave = segue.destination as! MoviesFavTableViewController
            showfave.sumcrsid = self.sumcrsid
            showfave.sumsbjid = self.sumsbjid
            showfave.id = self.id
            showfave.groupCode = self.groupCode
        }
    }
    func insertmoviesee(url : String, completionHandler : @escaping (String? , Error?)->()){
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
    
}
