//
//  Modelo.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 13/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import Foundation
import MapKit

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

class Ruta{
    
    var nombreRuta: String?
    var descripcionRuta: String?
    var favoritosRuta : [PuntoFavorito] = []
    
    init(nomRuta:String?,descRuta:String?,puntoInicial:PuntoFavorito){
        nombreRuta = nomRuta
        descripcionRuta = descRuta
        favoritosRuta.append(puntoInicial)
    }
}

class Evento{
    var nombreEvento: String!
    var tipoEvento: String!
    var coordenadasEvento: CLLocationCoordinate2D?
    var municipioEvento: String!
    var lugarEvento: String!
    var enlaceEvento: NSURL!
    var fechaEvento: String!
    
    init(nombreEvento:String, tipoEvento:String, municipioEvento: String, lugarEvento: String, fechaEvento: String ,enlaceEvento: NSURL ,coordenadasEvento: CLLocationCoordinate2D?){
        self.nombreEvento = nombreEvento
        self.tipoEvento = tipoEvento
        self.municipioEvento = municipioEvento
        self.lugarEvento = lugarEvento
        self.enlaceEvento = enlaceEvento
        self.coordenadasEvento = coordenadasEvento
        self.fechaEvento = fechaEvento
    }
    
}
