//
//  MoviesFavTableViewController.swift
//  kanoonRahbordi
//
//  Created by Tara Tandel on 5/10/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import AVFoundation


class MoviesFavTableViewCell : UITableViewCell {
    
    @IBOutlet weak var topicOfTheFavedMovies: UILabel!
    @IBOutlet weak var playImage: UIImageView!
}
class FavMovies {
    var DocumentId = Int()
    var FileTitle = String()
    var TeacherName = String()
    var M3u8Address = String()
}

class MoviesFavTableViewController: UITableViewController {
    var sumcrsid = Int()
    var sumsbjid = Int()
    var groupCode = Int()
    var id: Int = 0
    var favArray = [FavMovies]()
    
    @IBOutlet var favList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "http://www.kanoon.ir/Amoozesh/api/Document/GetFavoriteVideosNbA?userId=\(id)&groupcode=\(groupCode)&sumcrsid=\(sumcrsid)&sumsbjid=\(sumsbjid)"
        getFavInfo(URl: url){
            response , error in
            if response != nil{
                self.favArray.append(response!)
                self.favList.reloadData()
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favMovies", for: indexPath) as! MoviesFavTableViewCell
        cell.playImage?.image = #imageLiteral(resourceName: "play")
        cell.topicOfTheFavedMovies?.text = "\(favArray[indexPath.row].TeacherName) \n \(favArray[indexPath.row].FileTitle) "
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = favArray[indexPath.row].M3u8Address
        guard let url = URL(string: link) else {
            return
        }
        let player = AVPlayer(url: url)
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            player.play()
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func getFavInfo (URl : String , completionHandler : @escaping (FavMovies?, Error?) -> ()){
        Alamofire.request(URl).responseJSON{
            response in
            switch response.result{
            case .success(let value):
                let jsonValue = JSON(value)
                if let jsonArray = jsonValue.array{
                    for items in jsonArray {
                        let faveInfo = FavMovies()
                        faveInfo.DocumentId = items["DocumentId"].int!
                        faveInfo.FileTitle = items["FileTitle"].string!
                        faveInfo.M3u8Address = items["M3u8Address"].string!
                        faveInfo.TeacherName = items["TeacherName"].string!
                        completionHandler(faveInfo, nil )
                    }
                }
            case . failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
}
