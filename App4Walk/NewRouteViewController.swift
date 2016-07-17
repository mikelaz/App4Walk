//
//  NewRouteViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 13/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

//Definimos protocolo para comunicación con el delegado
protocol NewRouteViewControllerDelegate{
    func nuevaRutaDelegateMethod(nombreRuta: String, descripcionRuta: String)
}


class NewRouteViewController: UIViewController {

    
    @IBOutlet weak var nombreRuta: UITextField!
    @IBOutlet weak var descripcionRuta: UITextField!
    
    var delegate : NewRouteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func añadirNuevaRuta(sender: UIButton) {
        
        if nombreRuta.text != nil {
            //eliminamos los espacios en blanco que se hayan podido introducir al inicio y final del string
            let nombreRutaTrimmed = nombreRuta.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if nombreRutaTrimmed != ""{
                self.delegate?.nuevaRutaDelegateMethod(nombreRutaTrimmed!, descripcionRuta: descripcionRuta.text!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                nombreRuta.placeholder = "Introduzca Nombre Ruta"
            }
        }else{
            nombreRuta.placeholder = "Introduzca Nombre Ruta"
        }
    }
    
    
    @IBAction func cancelarNuevaRuta(sender: UIButton) {
       self.dismissViewControllerAnimated(true, completion: nil)
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
