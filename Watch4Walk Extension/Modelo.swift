//
//  Modelo.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 14/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import Foundation
import MapKit
import WatchKit

class PuntoFavorito {
    var nombreFavorito: String?
    var coordenadasFavorito: CLLocation?
    var fotoFavorito: UIImage?
    
    init (nomFav:String, coordenadasFav:CLLocation?, fotoFav:UIImage?){
        nombreFavorito = nomFav
        coordenadasFavorito = coordenadasFav
        fotoFavorito = fotoFav
    }
}


