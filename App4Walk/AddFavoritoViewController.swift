//
//  AddFavoritoViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 13/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit


//Definimos protocolo para comunicación con el delegado
protocol AddFavoritoViewControllerDelegate{
    func nuevoFavoritoDelegateMethod(nombreFav: String, fotoFav: UIImage?)
}


class AddFavoritoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nombreFavorito: UITextField!
    @IBOutlet weak var botonImagen: UIButton!
    
    var delegate: AddFavoritoViewControllerDelegate?
    
    let miPicker = UIImagePickerController()
    var fotoFavorito: UIImage!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        miPicker.delegate = self
        nombreFavorito.clearButtonMode = .Always
    }

    @IBAction func añadirNuevoFavorito(sender: UIButton) {
        //eliminamos los espacios en blanco que se hayan podido introducir al inicio y final del string
        let nombreFavTrimmed = nombreFavorito.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if nombreFavTrimmed != ""{
            self.delegate?.nuevoFavoritoDelegateMethod(nombreFavTrimmed!, fotoFav:fotoFavorito)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "Atención", message: "Introduzca un nombre para el punto favorito", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    

    @IBAction func incluirImagen() {
        let selector = UIAlertController(title: "Seleción Origen", message: "Selecione el origen desde el que insertar una imagen", preferredStyle: .Alert)
        selector.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil))
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            let takePictureAction = UIAlertAction(title: "Tomar Foto", style: .Default) { action -> Void in
                self.miPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.miPicker, animated: true, completion: nil)
            }
            selector.addAction(takePictureAction)
        }
        //Create and add a second option action
        let choosePictureAction = UIAlertAction(title: "Seleccionar de Album", style: .Default) { action -> Void in
            self.miPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.miPicker, animated: true, completion: nil)
        }
        selector.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(selector, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        fotoFavorito = image
        //Si hemos seleccionado una imagen, cambiamos el titulo del boton para que quede reflejado
        if fotoFavorito != nil{
            botonImagen.setTitle("Sustituir Imagen", forState: .Normal)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
