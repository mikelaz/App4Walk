//
//  DetalleFavoritoViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 18/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetalleFavoritoViewController: UIViewController {

    var puntoFavorito: FavoritoPointAnnotation?
    
    @IBOutlet weak var nombreFavorito: UILabel!
    @IBOutlet weak var imagenFavorito: UIImageView!
    @IBOutlet weak var latitudFavorito: UILabel!
    @IBOutlet weak var longitudFavorito: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nombreFavorito.text = puntoFavorito?.title
        latitudFavorito.text = String(puntoFavorito!.coordinate.latitude)
        longitudFavorito.text = String(puntoFavorito!.coordinate.longitude)
        if puntoFavorito?.fotografia != nil{
            imagenFavorito.image = puntoFavorito?.fotografia
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    
    @IBAction func compartirFavorito(sender: AnyObject) {
        let objetosParaCompartir: [AnyObject]!
        let vcard = locationVCardURLFromCoordinate(puntoFavorito!.coordinate)
        if vcard != nil{
            objetosParaCompartir = [puntoFavorito!.title!, puntoFavorito!.fotografia!,vcard!]
        }else{
            objetosParaCompartir = [puntoFavorito!.title!, puntoFavorito!.fotografia!]
        }
        let compartirVC = UIActivityViewController(activityItems: objetosParaCompartir, applicationActivities: nil)
        self.presentViewController(compartirVC, animated: true, completion: nil)
    }

    //Función que genera una vCard con la locacización a partir de un CLLocationCoordinate2D
    // Fuente original: https://gist.github.com/naturaln0va/e1fed3f1d32ecf951aac/
    //
    func locationVCardURLFromCoordinate(coordinate: CLLocationCoordinate2D) -> NSURL?
    {
        guard let cachesPathString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else {
            print("Error: couldn't find the caches directory.")
            return nil
        }
        
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            print("Error: the supplied coordinate, \(coordinate), is not valid.")
            return nil
        }
        
        let vCardString = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;Shared Location;;;",
            "FN:Shared Location",
            "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
            ].joinWithSeparator("\n")
        
        let vCardFilePath = (cachesPathString as NSString).stringByAppendingPathComponent("vCard.loc.vcf")
        
        do {
            try vCardString.writeToFile(vCardFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch let error {
            print("Error, \(error), saving vCard: \(vCardString) to file path: \(vCardFilePath).")
        }
        
        return NSURL(fileURLWithPath: vCardFilePath)
    }

}
