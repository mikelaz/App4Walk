//
//  DealleEventoViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 27/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import MapKit

class DetalleEventoViewController: UIViewController {

    var coordenadas: CLLocationCoordinate2D?
    var urlInformacion: NSURL!
    var nombre: String!
    var tipo: String!
    var municipio: String!
    var lugar: String!
    var fecha: String!
    
    @IBOutlet weak var campoNombre: UILabel!
    @IBOutlet weak var campoTipo: UILabel!
    @IBOutlet weak var campoMunicipio: UILabel!
    @IBOutlet weak var campoLugar: UILabel!
    @IBOutlet weak var campoFecha: UILabel!

    @IBOutlet weak var mapaDetalle: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        campoNombre.text = nombre
        campoTipo.text = tipo
        campoMunicipio.text = municipio
        campoLugar.text = lugar
        campoFecha.text = fecha
        
        //Pintar Pin con la localización del evento en el mapa
        if coordenadas != nil{
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: coordenadas!, span: span)
            mapaDetalle.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = coordenadas!
            pin.title = campoNombre.text
            mapaDetalle.addAnnotation(pin)
            
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func masInformacion() {
        UIApplication.sharedApplication().openURL(urlInformacion)
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
