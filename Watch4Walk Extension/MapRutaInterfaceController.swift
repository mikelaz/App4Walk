//
//  MapRutaInterfaceController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 14/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class MapRutaInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    @IBOutlet var mapaWatch: WKInterfaceMap!
    var locationManager: CLLocationManager = CLLocationManager()
    var localizacion: CLLocationCoordinate2D?
    var coordenadasFavoritos: [String:NSNumber]?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //Borramos todos los pines existentes
        self.mapaWatch.removeAllAnnotations()
        
        if context != nil{
            //Recorremos el diccionario que hemos generado desde la App iPhone y vamos pintando los puntos
            coordenadasFavoritos = context as? [String:NSNumber]
            for indice in 1...(coordenadasFavoritos!.count/2){
                let favoritoLat = coordenadasFavoritos!["\(indice)_lat"] as! CLLocationDegrees
                let favoritoLng = coordenadasFavoritos!["\(indice)_long"] as! CLLocationDegrees
                let punto = CLLocationCoordinate2D(latitude: favoritoLat, longitude: favoritoLng)
                self.mapaWatch.addAnnotation(punto, withPinColor: .Green)
                if indice == 1{
                    //Centramos el mapa en la posicion inicial de la ruta
                    let latDelta:CLLocationDegrees = 0.05
                    let lonDelta:CLLocationDegrees = 0.05
                    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                    let region = MKCoordinateRegion(center: punto, span: span)
                    self.mapaWatch.setRegion(region)
                    //Guardamos la localización del primer favorito
                    localizacion = punto
                }
            }
            
        }else{
            //mostramos posición actual
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestLocation()
        }
    }
    
    func centrarMapaPosicionUsuario(posicion: CLLocationCoordinate2D){
        let latDelta:CLLocationDegrees = 0.005
        let lonDelta:CLLocationDegrees = 0.005
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: posicion, span: span)
        self.mapaWatch.setRegion(region)
        self.mapaWatch.addAnnotation(posicion, withPinColor: .Red)

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        localizacion = locations[0].coordinate

        self.centrarMapaPosicionUsuario(localizacion!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    @IBAction func zoomMapa(value: Float) {
        if localizacion != nil{
            //Empezamos el zoom en 0.05 (intervalo 0.01-0.1). A valor menor, mayor zoom.
            let delta = CLLocationDegrees((10 - value) / 100)
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let region = MKCoordinateRegion(center: localizacion!, span: span)
            self.mapaWatch.setRegion(region)
        }else{
            print("Localizacion no disponible")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    


}
