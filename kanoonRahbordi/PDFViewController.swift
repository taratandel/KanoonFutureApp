//
//  PDFViewController.swift
//  kanoonRahbordi
//
//  Created by Tara Tandel on 4/31/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController,UIWebViewDelegate {
    
    var webView: UIWebView!
    var url = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlstr : URL! = URL(string: url)
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        view.addSubview(webView)
        webView.loadRequest(URLRequest(url: urlstr))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(shareTapped))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

