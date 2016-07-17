//
//  QRViewControllerCamara.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 12/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRViewControllerCamaraDelegate{
    func delegateMethod(capturaQR: String)
    func lanzarAlertaDelegateMethod(tituloAlerta: String, mensajeAlerta: String)
}

class QRViewControllerCamara: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        
    var sesionCaptura : AVCaptureSession?
    var layerCaptura : AVCaptureVideoPreviewLayer?
    var marcoQR : UIView?
    var urlValida : Bool?
    
    var delegate: QRViewControllerCamaraDelegate?
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.configurarCapturaVideo() == 0){
            self.configurarLayerCaptura()
        }
    }
        
    override func viewWillAppear(animated: Bool) {
        if (sesionCaptura?.running == false){
            sesionCaptura?.startRunning()
            marcoQR?.frame = CGRectZero
        }
    }
        
    func configurarCapturaVideo()->Int{
        let dispositivoCaptura = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do{
            let inputCaptura = try AVCaptureDeviceInput(device: dispositivoCaptura)
            sesionCaptura = AVCaptureSession()
            sesionCaptura?.addInput(inputCaptura)
            let salidaMetadatos = AVCaptureMetadataOutput()
            sesionCaptura?.addOutput(salidaMetadatos)
            salidaMetadatos.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            salidaMetadatos.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }catch let error as NSError? {
            if (error != nil) {
                self.delegate?.lanzarAlertaDelegateMethod("Escaneado no soportado", mensajeAlerta: "Su dispositivo no está soportado. Utilice un dispositivo con cámara")
                return -1
            }
        }
        return 0
    }
    
    func configurarLayerCaptura(){
        layerCaptura = AVCaptureVideoPreviewLayer(session: sesionCaptura!)
        layerCaptura?.videoGravity = AVLayerVideoGravityResizeAspectFill
        layerCaptura?.frame = self.view.layer.bounds
        self.view.layer.addSublayer(layerCaptura!)
        marcoQR = UIView()
        marcoQR?.layer.borderWidth = 3
        marcoQR?.layer.borderColor = UIColor.blueColor().CGColor
        self.view.addSubview(marcoQR!)
        if (sesionCaptura?.running == false){
            sesionCaptura?.startRunning()
        }
    }

        
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if (metadataObjects == nil || metadataObjects.count == 0){
            marcoQR?.frame = CGRectZero
            return
        }
        let objMetadato = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if (objMetadato.type == AVMetadataObjectTypeQRCode){
            let objCapturado = layerCaptura?.transformedMetadataObjectForMetadataObject(objMetadato as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            marcoQR?.frame = objCapturado.bounds
            if (objMetadato.stringValue != nil){
                /*if let url = NSURL(string: objMetadato.stringValue){
                    //Comprobamos que el QR escaneado contiene una URL válida llamando a Safari
                    urlValida = UIApplication.sharedApplication().canOpenURL(url)
                }*/
                //Comprobamos que el QR escaneado contiene una URL válida mediante función validarURL
                urlValida = self.validarURL(objMetadato.stringValue)
                if urlValida!{
                    sesionCaptura?.stopRunning()
                    self.delegate?.delegateMethod(objMetadato.stringValue)
                }else{
                    self.delegate?.lanzarAlertaDelegateMethod("URL Inválida", mensajeAlerta: "El QR escaneado no contiene una URL válida")
                }
            }
        }
    }
    
    func validarURL (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluateWithObject(urlString)
    }

}
