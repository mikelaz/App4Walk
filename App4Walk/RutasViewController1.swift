//
//  RutasViewController1.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 11/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import WatchConnectivity

class RutasViewController1: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, NewRouteViewControllerDelegate, AddFavoritoViewControllerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    private let manejador = CLLocationManager()
    private var usuarioLocalizado :Bool = false
    private var mostrandoRutaEnMapa : Bool = false
    
    @IBOutlet weak var botonMostrarRuta: UIBarButtonItem!
    @IBOutlet weak var botonFavorito: UIBarButtonItem!
    
    var rutas : [Ruta] = []
    
    //Objeto sesión WatchConnectivity comunicación con Watch
    var watchSession: WCSession?
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        mapa.delegate = self
        
        ///Configuración sesión WatchConnectivity
        if WCSession.isSupported() { //Comprueba que no se trata de un iPad o un iPod
            watchSession = WCSession.defaultSession()
            watchSession?.delegate = self
            watchSession?.activateSession()
        }
        //Envio de mensaje de prueba
        self.enviarMensajeWatch()
        //--
    }
    
    @IBAction func salirDeRutas(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func seleccionarTipoMapa(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            mapa.mapType = .Standard
        }else if sender.selectedSegmentIndex == 1{
            mapa.mapType = .Satellite
        }else if sender.selectedSegmentIndex == 2{
            mapa.mapType = .Hybrid
        }
    }
    
    //Función necesaria para que pinte la ruta en el mapa
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 4.0
        return renderer
    }

    func centrarMapaPosicionUsuario(){
        if manejador.location != nil{
            //Preparamos un objeto región para realizar el ZoomIn utilizando como centro la posición actual y un Span de 0.01 grados X e Y
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: manejador.location!.coordinate, span: span)
            mapa.setRegion(region, animated: true)
        }else{
            print("Localización no recibida")
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Si se trata de la primera lectura, establecemos el usuario como localizado
        if !usuarioLocalizado{
            usuarioLocalizado = true
        }
        //Centramos al usuario después de cada actualización
        self.centrarMapaPosicionUsuario()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "ERROR", message: "Error \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction (title: "OK", style: .Default, handler: nil)
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func insertarPin(punto: CLLocation, nombre: String){
       
        let pin = MKPointAnnotation()
        pin.coordinate = punto.coordinate
        pin.title = nombre
        mapa.addAnnotation(pin)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NuevaRuta" {
            if let controller = segue.destinationViewController as? NewRouteViewController {
                controller.popoverPresentationController!.delegate = self
                controller.delegate = self
            }
        }else if segue.identifier == "AñadirFavorito"{
            if let controller = segue.destinationViewController as? AddFavoritoViewController {
                controller.popoverPresentationController!.delegate = self
                controller.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        //Necesario para que en iPhone funcione la vista PopOver
        return UIModalPresentationStyle.None
    }
    
    
    func nuevaRutaDelegateMethod(nombreRuta: String, descripcionRuta: String){
        let localizacionActual = manejador.location
        
        //creamos el primer punto favorito en base a la localización actual
        let favorito = PuntoFavorito(nomFav: "Punto Inicial", coordenadasFav: localizacionActual!, fotoFav: nil)
        
        //Inicializamos el objeto ruta
        let ruta = Ruta(nomRuta: nombreRuta,descRuta: descripcionRuta,puntoInicial: favorito)
        //Añadimos el objeto ruta al array de rutas
        rutas.append(ruta)
        //Borramos todos los pins que hubiese en el mapa de anteriores rutas
        let annotationsToRemove = mapa.annotations.filter { $0 !== mapa.userLocation }
        mapa.removeAnnotations(annotationsToRemove)
        //Añadimos el pin en el mapa con el primer punto favorito
        self.insertarPin(manejador.location!, nombre: favorito.nombreFavorito!)
        
        //si se ha creado la primera ruta, activamos los botones de añadir favorito y mostrar ruta en el mapa
        if (self.botonMostrarRuta.enabled == false && self.botonFavorito.enabled == false){
            self.botonFavorito.enabled = true
            self.botonMostrarRuta.enabled = true
        }
        //Volcamos el nombre de la ruta actual en la consola
        print("Ruta " + rutas[rutas.count-1].nombreRuta! + " creada")
    }
    
    func nuevoFavoritoDelegateMethod(nombreFav: String, fotoFav: UIImage?){
        let localizacionActual = manejador.location
        let indiceRuta = rutas.count - 1
        
        //creamos el punto favorito en base a la localización actual
        let favorito = PuntoFavorito(nomFav: nombreFav, coordenadasFav: localizacionActual!, fotoFav: fotoFav)
        
        rutas[indiceRuta].favoritosRuta.append(favorito)
        //Añadimos el pin correspondiente al punto favorito en el mapa
        self.insertarPin(manejador.location!, nombre: favorito.nombreFavorito!)
        //Llamamos a la función encargada de enviar el contexto actualizado a Watch
        self.enviarContextoWatch()
    }
    
    func obtenerRuta(origen: MKMapItem, destino: MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .Walking
        //Código Swift 2.0 para realizar la petición 
        let directions = MKDirections(request: solicitud)
        directions.calculateDirectionsWithCompletionHandler{
            respuesta, error in
            guard let respuesta = respuesta else {
                //handle the error here
                print("Error al obtener la ruta")
                return
            }
            self.dibujarRutaEnMapa(respuesta)
        }
        
    }
    
    func dibujarRutaEnMapa(respuesta: MKDirectionsResponse){
        //Centramos el mapa en el punto inicial
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: respuesta.source.placemark.coordinate, span: span)
        mapa.setRegion(region, animated: true)
        //Dibujamos la ruta en el mapa
        for ruta in respuesta.routes{
            self.mapa.addOverlay(ruta.polyline, level: MKOverlayLevel.AboveRoads)
            //Volcamos las instrucciones en la consola
            for paso in ruta.steps{
                print(paso.instructions)
            }
        }
    }

    func muestraRutaFavoritos(){
        //Esta función calcula y muestra la ruta que forman los diferentes favoritos almacenados en la ruta actual terminando en el punto actual
        let indexRutaActual = rutas.count - 1
        let numeroFavoritos = rutas[indexRutaActual].favoritosRuta.count
        let favoritos = rutas[indexRutaActual].favoritosRuta
        var index = 0
        var origen : MKMapItem!
        var destino: MKMapItem!
        
        if numeroFavoritos == 1{
            //Si sólo existe el favorito de arranque de ruta, mostramos la ruta entre el punto inicial y la posición actual
            origen = MKMapItem(placemark: MKPlacemark(coordinate: favoritos[numeroFavoritos-1].coordenadasFavorito!.coordinate, addressDictionary: nil))
            destino = MKMapItem(placemark: MKPlacemark(coordinate: manejador.location!.coordinate, addressDictionary: nil))
            self.obtenerRuta(origen, destino: destino)
        }else{
            //Recorremos los favoritos para crear rutas entre cada dos puntos
            for favorito in favoritos{
                if index < numeroFavoritos - 1{
                    origen = MKMapItem(placemark: MKPlacemark(coordinate: favorito.coordenadasFavorito!.coordinate, addressDictionary: nil))
                    destino = MKMapItem(placemark: MKPlacemark(coordinate: favoritos[index+1].coordenadasFavorito!.coordinate, addressDictionary: nil))
                    self.obtenerRuta(origen, destino: destino)
                    index += 1
                }
                
            }
        }
    }

    @IBAction func mostrarRuta(sender: UIBarButtonItem) {
        if !mostrandoRutaEnMapa{
            mostrandoRutaEnMapa = true
            //Cambiamos el boton para que muestre la opción de volver al tracking
            botonMostrarRuta.title = "Ver Tracking"
            //Detenemos de actualizar la localización
            self.manejador.stopUpdatingLocation()
            self.mapa.showsUserLocation = false
            //mostramos la ruta generada
            self.muestraRutaFavoritos()
        }else{
            //Volvemos al modo tracking
            mostrandoRutaEnMapa = false
            botonMostrarRuta.title = "Ver Ruta"
            //Borramos la ruta del mapa
            self.mapa.removeOverlays(self.mapa.overlays)
            //Volvemos a activar la localización
            self.manejador.startUpdatingLocation()
            self.mapa.showsUserLocation = true
        }
        
    }
    //Pruebas de comunicacion con el Watch a través de Watchconnectivity
    func enviarMensajeWatch() {
        if let session =  watchSession where session.reachable {
            session.sendMessage(["mensaje": "😼"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    func enviarContextoWatch(){
        //Utilizamos un diccionario para enviar el contexto a la App WatchOS
        //Por cada favorito, enviamos su latitud y longitud convertidas a NSNumber
        var contexto = [String:NSNumber]()
        let indiceRuta = rutas.count - 1
        var index = 1
        for favorito in rutas[indiceRuta].favoritosRuta{
            let lat : NSNumber = NSNumber(double: (favorito.coordenadasFavorito?.coordinate.latitude)!)
            let lng : NSNumber = NSNumber(double: (favorito.coordenadasFavorito?.coordinate.longitude)!)
            contexto["\(index)_lat"] = lat
            contexto["\(index)_long"] = lng
            index += 1
        }
        do {
            let session = WCSession.defaultSession()
            try session.updateApplicationContext(contexto)
            
        } catch let error as NSError {
            print("Error: \(error.description)")
        }
        
    }
}

//Extension desde la que controlamos la información recibida
extension RutasViewController1: WCSessionDelegate {
    
}


