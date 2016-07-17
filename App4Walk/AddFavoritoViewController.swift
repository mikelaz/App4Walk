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
    
    @IBOutlet weak var botonFotoCamara: UIButton!
    
    var delegate: AddFavoritoViewControllerDelegate?
    
    let miPicker = UIImagePickerController()
    var fotoFavorito: UIImage!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UIImagePickerController.isSourceTypeAvailable(.Camera){
            botonFotoCamara.hidden = true
        }
        miPicker.delegate = self
    }

    @IBAction func añadirNuevoFavorito(sender: UIButton) {
        if nombreFavorito.text != nil {
            //eliminamos los espacios en blanco que se hayan podido introducir al inicio y final del string
            let nombreFavTrimmed = nombreFavorito.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if nombreFavTrimmed != ""{
                self.delegate?.nuevoFavoritoDelegateMethod(nombreFavTrimmed!, fotoFav:fotoFavorito)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                nombreFavorito.placeholder = "Introduzca Nombre Favorito"
            }
        }else{
            nombreFavorito.placeholder = "Introduzca Nombre Favorito"
        }
        
    }
   
    @IBAction func cancelarNuevoFavorito(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func añadirFotoAlbum(sender: UIButton) {
        miPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(miPicker, animated: true, completion: nil)
    }
    
    @IBAction func añadirFotoCamara(sender: UIButton) {
        miPicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(miPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        fotoFavorito = image
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
