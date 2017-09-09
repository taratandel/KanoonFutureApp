//
//  ViewController.swift
//  kanoonRahbordi
//
//  Created by negar on 96/Khordad/07 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backGround: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        backGround.image = #imageLiteral(resourceName: "enter")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false

    }


}

