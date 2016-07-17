//
//  InterfaceController.swift
//  Watch4Walk Extension
//
//  Created by Mikel Aguirre on 14/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    var favoritosMapa: [PuntoFavorito] = []
    //Objeto sesión comunicación WatchConnectivity
    var sesion: WCSession?
    //---
    var coordenadasFavoritos: [String:NSNumber]?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //Configuración sesión comunicación WatchConnectivity
        if (WCSession.isSupported()) {
            sesion = WCSession.defaultSession()
            sesion?.delegate = self
            sesion?.activateSession()
        }
        //---
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func mostrarRuta() {
        if coordenadasFavoritos == nil{
            print("Watch - coordenadas no recibidas")
        }
        pushControllerWithName("controladorMapa", context: coordenadasFavoritos)
    }

}

//Extension desde la que controlamos la información recibida
extension InterfaceController: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let mensaje = message["mensaje"] as? String {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("mensaje recibido  \(mensaje)")
            })
        }
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Contexto recibido")
        coordenadasFavoritos = applicationContext as? [String:NSNumber]
        print(coordenadasFavoritos!["1_lat"])
    }
    
}