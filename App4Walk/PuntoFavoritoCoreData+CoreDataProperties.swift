//
//  PuntoFavoritoCoreData+CoreDataProperties.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 19/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PuntoFavoritoCoreData {

    @NSManaged var fotoFavorito: NSData?
    @NSManaged var nombreFavorito: String?
    @NSManaged var latitudFavorito: NSNumber?
    @NSManaged var longitudFavorito: NSNumber?
    @NSManaged var rutaDeFavorito: RutaCoreData?

}
