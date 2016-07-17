//
//  NavConQR.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 11/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class NavConQR: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let origen = sender as! QRViewController1
        let destino = segue.destinationViewController as! QRViewController2
        //origen.sesionCaptura?.stopRunning()
        destino.urlRecivida = origen.urlCapturada
    }

}
