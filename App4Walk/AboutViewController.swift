//
//  AboutViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 22/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cerrar(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
