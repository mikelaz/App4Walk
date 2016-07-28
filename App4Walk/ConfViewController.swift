//
//  ConfViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 23/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

protocol ConfViewControllerDelegate{
    func configuraTipoMapaDelegateMethod(tipoMapa:Int)
    func configuraTipoRutaDelegateMethod(tipoRuta:Int)
}

class ConfViewController: UIViewController {

    var tipoMapaSeleccionado: Int!
    var tipoRutaSeleccionado: Int!
    
    @IBOutlet weak var selectorMapa: UISegmentedControl!
    @IBOutlet weak var selectorRuta: UISegmentedControl!
    
    var delegate: ConfViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tipoMapaSeleccionado == 0{
            selectorMapa.selectedSegmentIndex = 0
        }else if tipoMapaSeleccionado == 1{
            selectorMapa.selectedSegmentIndex = 1
        }else if tipoMapaSeleccionado == 2{
            selectorMapa.selectedSegmentIndex = 2
        }
        if tipoRutaSeleccionado == 0{
            selectorRuta.selectedSegmentIndex = 0
        }else if tipoRutaSeleccionado == 1{
            selectorRuta.selectedSegmentIndex = 1
        }else if tipoRutaSeleccionado == 2{
            selectorRuta.selectedSegmentIndex = 2
        }
    }

    
    @IBAction func configuraMapa(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.delegate?.configuraTipoMapaDelegateMethod(0)
        }else if sender.selectedSegmentIndex == 1{
            self.delegate?.configuraTipoMapaDelegateMethod(1)
        }else if sender.selectedSegmentIndex == 2{
            self.delegate?.configuraTipoMapaDelegateMethod(2)
        }
    }
    
    @IBAction func configuraRuta(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.delegate?.configuraTipoRutaDelegateMethod(0)
        }else if sender.selectedSegmentIndex == 1{
            self.delegate?.configuraTipoRutaDelegateMethod(1)
        }else if sender.selectedSegmentIndex == 2{
            self.delegate?.configuraTipoRutaDelegateMethod(2)
        }
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
