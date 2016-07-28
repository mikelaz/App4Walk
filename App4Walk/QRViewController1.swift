//
//  QRViewController1.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 11/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class QRViewController1: UIViewController, QRViewControllerCamaraDelegate {

    var urlCapturada : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    
    func delegateMethod(capturaQR: String){
        self.urlCapturada = capturaQR
        let navCont = self.navigationController
        navCont?.performSegueWithIdentifier("presentaQR", sender: self)
    }
    
    func lanzarAlertaDelegateMethod(tituloAlerta: String, mensajeAlerta: String){
        let alerta = UIAlertController(title: tituloAlerta, message: mensajeAlerta, preferredStyle: .Alert)
        alerta.addAction(UIAlertAction (title: "OK", style: .Default, handler: nil))
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //IMPORTANTE: En la siguiente línea creamos la referencia al delegado que utilizaremos desde el controlador child
        if segue.identifier == "vistaEmbebida"{
            let cargaEmbebido = segue.destinationViewController as! QRViewControllerCamara
            cargaEmbebido.delegate = self
        }
    }
    
    @IBAction func salirCapturaQR(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
