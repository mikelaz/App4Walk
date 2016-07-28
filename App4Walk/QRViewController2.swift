//
//  QRViewController2.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 11/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class QRViewController2: UIViewController {

    
    @IBOutlet weak var vistaNavegador: UIWebView!
    var urlRecivida : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: urlRecivida!)
        let request = NSURLRequest(URL: url!)
        vistaNavegador.loadRequest(request)
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
