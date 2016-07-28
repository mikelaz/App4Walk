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
import CoreData

class RutasViewController1: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, NewRouteViewControllerDelegate, AddFavoritoViewControllerDelegate, RutasTableViewController2Delegate, ConfViewControllerDelegate, ARDataSource {

    @IBOutlet weak var mapa: MKMapView!
    private let manejador = CLLocationManager()
    private var usuarioLocalizado :Bool = false
    private var mostrandoRutaEnMapa : Bool = false
    private var puntoSeleccionado: FavoritoPointAnnotation?
    
    var tipoMapaSeleccionado: Int = 0
    var tipoRutaSeleccionado: Int = 0
    
    @IBOutlet weak var botonMostrarLocalizacion: UIBarButtonItem!
    @IBOutlet weak var botonMostrarRutas: UIBarButtonItem!
    @IBOutlet weak var botonMostrarRuta: UIBarButtonItem!
    @IBOutlet weak var botonFavorito: UIBarButtonItem!
    @IBOutlet weak var botonLanzarQR: UIBarButtonItem!
    @IBOutlet weak var botonLanzarRA: UIBarButtonItem!
    @IBOutlet weak var botonNuevaRuta: UIBarButtonItem!
    //Creamos un objeto UIButton que utilizaremos como CustomView para modificar el icono del UIBarButton "botonFavorito"
    let botonTemp = UIButton()

    //Contexto CoreData
    var managedObjectContext: NSManagedObjectContext!
    //Variables para version CoreData
    var nombreRutaActual = String()
    var rutaActual: RutaCoreData!
    
    //Objeto sesión WatchConnectivity comunicación con Watch
    var watchSession: WCSession?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Arranque del manejador de localización
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        //Delegado MKMapViewDelegate
        mapa.delegate = self
        
        ///Configuración sesión WatchConnectivity----------------------------------------
        if WCSession.isSupported() { //Comprueba que no se trata de un iPad o un iPod
            watchSession = WCSession.defaultSession()
            watchSession?.delegate = self
            watchSession?.activateSession()
        }
        //Envio de mensaje de prueba
        self.enviarMensajeWatch()
        //-------------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------------------------------------
        //Codigo para inicializar la vista Custom que asignaremos al "botonFavorito"
        //Basado en http://www.jobinandjismi.com/how-to-change-uibarbuttonitem-image-programmatically-in-swift/
        //--------------------------------------------------------------------------------------------------------
        botonTemp.setImage(UIImage(named: "Icono_Barra_VerRuta"), forState: .Normal)
        botonTemp.frame = CGRectMake(0, 0, 40, 40)
        botonTemp.addTarget(self,action:#selector(RutasViewController1.mostrarRuta(_:)),forControlEvents:.TouchUpInside)
        botonMostrarRuta.customView = botonTemp
    }
    
    @IBAction func salirDeRutas(sender: UIBarButtonItem) {
        self.usuarioLocalizado = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Funciones llamadas desde el POPUP de configuración de Mapa y Ruta-----------------
    func configuraTipoMapaDelegateMethod(tipoMapa:Int){
        if tipoMapa == 0{
            mapa.mapType = .Standard
            tipoMapaSeleccionado = 0
        }else if tipoMapa == 1{
            mapa.mapType = .Satellite
            tipoMapaSeleccionado = 1
        }else if tipoMapa == 2{
            mapa.mapType = .Hybrid
            tipoMapaSeleccionado = 2
        }
    }
    
    func configuraTipoRutaDelegateMethod(tipoRuta:Int){
        if tipoRuta == 0{
            tipoRutaSeleccionado = 0
        }else if tipoRuta == 1{
            tipoRutaSeleccionado = 1
        }else if tipoRuta == 2{
            tipoRutaSeleccionado = 2
        }
    }
    //----------------------------------------------------------------------------------
    
    @IBAction func centrarLocUsuario(sender: UIBarButtonItem) {
        //Centramos al usuario en el mapa
        self.centrarMapaPosicionUsuario()
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
            self.centrarMapaPosicionUsuario()
            usuarioLocalizado = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "Error recibiendo localización", message: "Es posible que Ud. se encuentre dentro de un edificio", preferredStyle: .Alert)
        let accionOK = UIAlertAction (title: "OK", style: .Default, handler: nil)
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    //Utilizamos la clase FavoritoPointAnnotation que hemos generado para incluir una foto en el objeto
    func insertarPin(punto: CLLocation, nombre: String, imagen: UIImage?){
        let pin = FavoritoPointAnnotation()
        pin.coordinate = punto.coordinate
        pin.title = nombre
        pin.fotografia = imagen
        mapa.addAnnotation(pin)
     
     }
    //Modificamos la presentación del Annotation en el mapa para que tenga un boton que nos lleve a la vista de detalle del favorito
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //Si se trata del punto que muestra nuestra posición, no hacemos nada
        if (annotation is MKUserLocation) {
            return nil
        }
        let identificador = "pinFavorito"
        
        var vistaMapa = mapView.dequeueReusableAnnotationViewWithIdentifier(identificador)
        if vistaMapa == nil {
            vistaMapa = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identificador)
            vistaMapa?.canShowCallout = true
            vistaMapa?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            vistaMapa?.annotation = annotation
        }
        return vistaMapa
    }
    
    //Navegación - Segues-------------------------------------------------------------------------------------------------------
    
    //Llevamos a cabo el segue a la vista detalle del favorito si pulsamos el boton introducido en la función anterior
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            puntoSeleccionado = view.annotation as? FavoritoPointAnnotation
            performSegueWithIdentifier("VerDetalleFavorito", sender: self)
        }
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
        }else if segue.identifier == "VerDetalleFavorito"{
            if let controller = segue.destinationViewController as? DetalleFavoritoViewController {
                controller.puntoFavorito = puntoSeleccionado
            }
        }else if segue.identifier == "ListadoRutas"{
            if let controller = segue.destinationViewController as? UINavigationController {
                let tablaRutas = controller.topViewController as! RutasTableViewController2
                tablaRutas.managedObjectContext = self.managedObjectContext
                tablaRutas.nombreRutaSeleccionada = self.nombreRutaActual
                tablaRutas.delegate = self
            }
        }else if segue.identifier == "ConfigRutaMapa"{
            if let controller = segue.destinationViewController as? ConfViewController {
                controller.popoverPresentationController!.delegate = self
                controller.delegate = self
                controller.tipoRutaSeleccionado = self.tipoRutaSeleccionado
                controller.tipoMapaSeleccionado = self.tipoMapaSeleccionado
            }
        }
    }
    
    //Código necesario para que en iPhone funcione la vista PopOver
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.None
    }
    //---------------------------------------------------------------------------------------------------------------------------
    
    //Función de generación de una nueva ruta llamada desde el POPUP Nueva Ruta-----------------------------------------------------------
    func nuevaRutaDelegateMethod(nombreRuta: String, descripcionRuta: String){
        let localizacionActual = manejador.location
        
        let resultado = guardarNuevaRuta(nombreRuta, descripcion: descripcionRuta, coordenadasPuntoInicial: localizacionActual!.coordinate)
        if resultado == 0{
            print("Guardada la ruta \(nombreRuta)")
            nombreRutaActual = nombreRuta
            
            //Borramos todos los pins que hubiese en el mapa de anteriores rutas
            let annotationsToRemove = mapa.annotations.filter { $0 !== mapa.userLocation }
            mapa.removeAnnotations(annotationsToRemove)
            
            //Añadimos el pin en el mapa con el primer punto favorito
            self.insertarPin(manejador.location!, nombre: "Punto Inicial", imagen: nil)
            
            //si se ha creado la primera ruta, activamos los botones de añadir favorito y mostrar ruta en el mapa
            if (self.botonMostrarRuta.enabled == false && self.botonFavorito.enabled == false){
                self.botonFavorito.enabled = true
                self.botonMostrarRuta.enabled = true
            }

        }else{
            print("Error al guardadar la ruta \(nombreRuta)")
        }
    }
    //-------------------------------------------------------------------------------------------------------------------------------------

    //Función de generación de un nuevo favorito llamada desde el POPUP Nueva Ruta-----------------------------------------------------------
    func nuevoFavoritoDelegateMethod(nombreFav: String, fotoFav: UIImage?){
        let localizacionActual = manejador.location
        
        let resultado = guardarNuevoFavorito(nombreRutaActual, nombreFavorito: nombreFav, coordenadasFavorito: localizacionActual!.coordinate, imagen: fotoFav)
        if resultado == 0{
            print("Guardado el favorito en la ruta \(nombreRutaActual)")
            //Añadimos el pin correspondiente al punto favorito en el mapa
            self.insertarPin(localizacionActual!, nombre: nombreFav, imagen: fotoFav)
            //Enviamos contexto a Watch
            //Llamamos a la función encargada de enviar el contexto actualizado a Watch
            self.enviarContextoWatch(nombreRutaActual)
        }else{
            print("fallo")
        }
        
    }
    //-------------------------------------------------------------------------------------------------------------------------------------
    
    
    //Obtención y dibujo de ruta en mapa-----------------------------------------------------------------------
    func obtenerRuta(origen: MKMapItem, destino: MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        if self.tipoRutaSeleccionado == 0{
            solicitud.transportType = .Walking
        }else if self.tipoRutaSeleccionado == 1{
            solicitud.transportType = .Automobile
        }else if self.tipoRutaSeleccionado == 2{
            solicitud.transportType = .Any
        }
        //Código Swift 2.0 para realizar la petición 
        let directions = MKDirections(request: solicitud)
        directions.calculateDirectionsWithCompletionHandler{
            response, error in
            guard let respuesta = response else {
                //handle the error here
                print("Error al obtener la ruta: \(error?.localizedDescription)")
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

    
    func muestraRutaFavoritos(nombreRuta:String){
        //Esta función calcula y muestra la ruta que forman los diferentes favoritos almacenados en la ruta actual terminando en el punto actual
        var index = 1
        var origen : MKMapItem!
        var destino: MKMapItem!

        let favoritos = self.obtenerFavoritosDeRuta(nombreRuta)
        if favoritos != nil{
            if favoritos?.count == 1{
                //Si sólo existe el favorito de arranque de ruta, mostramos la ruta entre el punto inicial y la posición actual
                let coordenadas = CLLocationCoordinate2D(latitude: CLLocationDegrees(favoritos![0].latitudFavorito!), longitude: CLLocationDegrees(favoritos![0].longitudFavorito!))
                origen = MKMapItem(placemark: MKPlacemark(coordinate: coordenadas, addressDictionary: nil))
                destino = MKMapItem(placemark: MKPlacemark(coordinate: manejador.location!.coordinate, addressDictionary: nil))
                self.obtenerRuta(origen, destino: destino)
            }else{
                //Recorremos los favoritos para crear rutas entre cada dos puntos
                for favorito in favoritos!{
                    //Utilizamos la variable index para obtener el punto favorito+1
                    if index < favoritos?.count {
                        var coordenadas = CLLocationCoordinate2D(latitude: CLLocationDegrees(favorito.latitudFavorito!), longitude: CLLocationDegrees(favorito.longitudFavorito!))
                        origen = MKMapItem(placemark: MKPlacemark(coordinate: coordenadas, addressDictionary: nil))
                        coordenadas = CLLocationCoordinate2D(latitude: CLLocationDegrees(favoritos![index].latitudFavorito!), longitude: CLLocationDegrees(favoritos![index].longitudFavorito!))
                        destino = MKMapItem(placemark: MKPlacemark(coordinate: coordenadas, addressDictionary: nil))
                        self.obtenerRuta(origen, destino: destino)
                        index += 1
                    }
                }
            }
        }
       
    }
    

    func mostrarRuta(sender: UIBarButtonItem) {
        if !mostrandoRutaEnMapa{
            mostrandoRutaEnMapa = true
            //Cambiamos el boton para que muestre la opción de volver al tracking
            //Utilizamos la vista custom UIButton que hemos generado para poder cambiar el icono al BarButton
            botonTemp.setImage(UIImage(named: "Icono_Barra_VerTracking"), forState: .Normal)
            //Detenemos de actualizar la localización
            self.manejador.stopUpdatingLocation()
            self.mapa.showsUserLocation = false
            //mostramos la ruta generada
            self.muestraRutaFavoritos(nombreRutaActual)
            //Desactivamos todos los botones de la barra
            self.botonNuevaRuta.enabled = false
            self.botonMostrarRutas.enabled = false
            self.botonMostrarLocalizacion.enabled = false
            self.botonFavorito.enabled = false
            self.botonLanzarQR.enabled = false
            self.botonLanzarRA.enabled = false
        }else{
            //Volvemos al modo tracking
            mostrandoRutaEnMapa = false
             //Utilizamos la vista custom UIButton que hemos generado para poder cambiar el icono al BarButton
            botonTemp.setImage(UIImage(named: "Icono_Barra_VerRuta"), forState: .Normal)
            //Borramos la ruta del mapa
            self.mapa.removeOverlays(self.mapa.overlays)
            //Volvemos a activar la localización
            self.manejador.startUpdatingLocation()
            self.mapa.showsUserLocation = true
            //Activamos todos los botones de la barra
            self.botonNuevaRuta.enabled = true
            self.botonMostrarRutas.enabled = true
            self.botonMostrarLocalizacion.enabled = true
            self.botonFavorito.enabled = true
            self.botonLanzarQR.enabled = true
            self.botonLanzarRA.enabled = true
        }
        
    }
    //------------------------------------------------------------------------------------------------------------------

    
    //función que recibe los cambios realizados al salir de la vista Tabla de Rutas
    func actualizacionRutasDelegatedMethod(moc: NSManagedObjectContext, nombreRutaSeleccionada:String){
        self.managedObjectContext = moc
        self.cargarRutaEnMapa(nombreRutaSeleccionada)
        
    }
    
    func cargarRutaEnMapa(nombreRuta: String){
        // si volvemos sin realizar cambios, lo dejamos como está
        if nombreRutaActual != nombreRuta{
            //nombreRuta es "" cuando se ha borrado la ruta activa
            if nombreRuta == ""{
                rutaActual = nil
                nombreRutaActual = ""
                //Borramos todos los pins que hubiese en el mapa de anteriores rutas
                let annotationsToRemove = mapa.annotations.filter { $0 !== mapa.userLocation }
                mapa.removeAnnotations(annotationsToRemove)
                //desactivamos los botones de Mostrar Ruta y añadir Favorito
                self.botonFavorito.enabled = false
                self.botonMostrarRuta.enabled = false
            }else{
                //si hemos vuelto de la tabla de rutas después de realizar algún cambio, cargamos la nueva ruta en el mapa
                nombreRutaActual = nombreRuta
                //Borramos todos los pins que hubiese en el mapa de anteriores rutas
                let annotationsToRemove = mapa.annotations.filter { $0 !== mapa.userLocation }
                mapa.removeAnnotations(annotationsToRemove)
                let favoritos = self.obtenerFavoritosDeRuta(nombreRuta)
                for favorito in favoritos!{
                    let pin = FavoritoPointAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(favorito.latitudFavorito!), longitude: CLLocationDegrees(favorito.longitudFavorito!))
                    pin.title = favorito.nombreFavorito
                    if favorito.fotoFavorito != nil{
                        pin.fotografia = UIImage(data: favorito.fotoFavorito!)
                    }else{
                        pin.fotografia = nil
                    }
                    mapa.addAnnotation(pin)
                }
                //si no había ruta activa, activamos los botones de añadir favorito y mostrar ruta en el mapa
                if (self.botonMostrarRuta.enabled == false && self.botonFavorito.enabled == false){
                    self.botonFavorito.enabled = true
                    self.botonMostrarRuta.enabled = true
                }
                /* Si estábamos en modo Ver Ruta, eliminamos la ruta anterior del mapa y volvemos al modo tracking
                if mostrandoRutaEnMapa{
                    mostrandoRutaEnMapa = false
                    //Utilizamos la vista custom UIButton que hemos generado para poder cambiar el icono al BarButton
                    botonTemp.setImage(UIImage(named: "Icono_Barra_VerRuta"), forState: .Normal)
                    //Borramos la ruta del mapa
                    self.mapa.removeOverlays(self.mapa.overlays)
                    //Volvemos a activar la localización
                    self.manejador.startUpdatingLocation()
                    self.mapa.showsUserLocation = true
                    //Activamos todos los botones de la barra
                    self.botonMostrarRutas.enabled = true
                    self.botonMostrarLocalizacion.enabled = true
                    self.botonFavorito.enabled = true
                    self.botonLanzarQR.enabled = true
                    self.botonLanzarRA.enabled = true
                }*/
            }
        }
    }
    
    //Watchconnectivity-------------------------------------------------------------------------------------
    
    //Pruebas de comunicacion con el Watch a través de Watchconnectivity
    func enviarMensajeWatch() {
        if let session =  watchSession where session.reachable {
            session.sendMessage(["mensaje": "😼"], replyHandler: nil, errorHandler: { (error) -> Void in
                print(error)
            })
        }
    }
    
    
    func enviarContextoWatch(nombreRuta:String){
        //Utilizamos un diccionario para enviar el contexto a la App WatchOS
        //Por cada favorito, enviamos su latitud y longitud convertidas a NSNumber
        var contexto = [String:NSNumber]()
        let favoritos = self.obtenerFavoritosDeRuta(nombreRuta)
        var index = 1
        if favoritos != nil{
            for favorito in favoritos!{
                let lat = favorito.latitudFavorito!
                let lng = favorito.longitudFavorito!
                contexto["\(index)_lat"] = lat
                contexto["\(index)_long"] = lng
                index += 1
            }
            do {
                let session = WCSession.defaultSession()
                try session.updateApplicationContext(contexto)
                
            } catch let error as NSError {
                print("Error enviando contexto a Watch: \(error.localizedDescription)")
            }
        }
    }
    //--------------------------------------------------------------------------------------------------------
    
    //Funciones CoreData------------------------------------------------------------------------------------------

    func compruebaExistenciaRuta(nombreRuta:String)->Int{
        //Devuelve 1 si existe, 0 si no existe y -1 en caso de error
        let resultado: Int
        let rutasEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.managedObjectContext)
        let consulta = rutasEntidad!.managedObjectModel.fetchRequestFromTemplateWithName("existeRuta", substitutionVariables: ["nombreConsulta":nombreRuta])
        do{
            let resultadoConsulta = try self.managedObjectContext.executeFetchRequest(consulta!)
            if resultadoConsulta.count > 0{
                resultado = 1
            }else{
                resultado = 0
            }
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            resultado = -1
            
        }
        return resultado
    }
    
    func guardarNuevaRuta(nombre:String, descripcion:String, coordenadasPuntoInicial:CLLocationCoordinate2D)->Int{
        let comprueba = self.compruebaExistenciaRuta(nombre)
        if  comprueba == 1{
            return 1
        }else if comprueba == -1{
            return -1
        }else{
            let ruta = NSEntityDescription.insertNewObjectForEntityForName("Ruta", inManagedObjectContext: self.managedObjectContext) as! RutaCoreData
            ruta.nombreRuta = nombre
            ruta.descripcionRuta = descripcion
            //utilizamos la relación to_one que PuntoFavoritoCoreData tiene contra RutaCoreData
            let punto = NSEntityDescription.insertNewObjectForEntityForName("PuntoFavorito", inManagedObjectContext: self.managedObjectContext) as! PuntoFavoritoCoreData
            punto.nombreFavorito = "Punto Incial"
            punto.latitudFavorito = coordenadasPuntoInicial.latitude
            punto.longitudFavorito = coordenadasPuntoInicial.longitude
            punto.fotoFavorito = nil
            rutaActual = ruta
            punto.rutaDeFavorito = rutaActual
            //guardamos el contexto
            do {
                try self.managedObjectContext.save()
            } catch let error as NSError {
                print("Error guardando: \(error.localizedDescription)")
                return -1
            }
            return 0
        }
        
    }
    
    func guardarNuevoFavorito(nombreRuta:String, nombreFavorito: String, coordenadasFavorito:CLLocationCoordinate2D, imagen:UIImage?)->Int{
        let comprueba = self.compruebaExistenciaRuta(nombreRuta)
        if  comprueba == 1{
            //Dado que existe la ruta, recuperamos la misma para añadir el punto favortio
            let rutaFetch = NSFetchRequest(entityName: "Ruta")
            rutaFetch.predicate = NSPredicate(format: "nombreRuta == %@", nombreRuta)
            do {
                let resultadoConsulta = try self.managedObjectContext.executeFetchRequest(rutaFetch) as! [RutaCoreData]
                if resultadoConsulta.count > 0 {
                    rutaActual = resultadoConsulta.first
                }
            }catch let error as NSError {
                print("Error recuperando ruta: \(error.localizedDescription)")
                return -1
            }
            //utilizamos la relación to_one que PuntoFavoritoCoreData tiene contra RutaCoreData
            let punto = NSEntityDescription.insertNewObjectForEntityForName("PuntoFavorito", inManagedObjectContext: self.managedObjectContext) as! PuntoFavoritoCoreData
            punto.nombreFavorito = nombreFavorito
            punto.latitudFavorito = coordenadasFavorito.latitude
            punto.longitudFavorito = coordenadasFavorito.longitude
            if imagen != nil{
                punto.fotoFavorito = UIImagePNGRepresentation(imagen!)
            }else{
                punto.fotoFavorito = nil
            }
            punto.rutaDeFavorito = rutaActual
            //guardamos el contexto
            do {
                try self.managedObjectContext.save()
            } catch let error as NSError {
                print("Error guardando: \(error.localizedDescription)")
                return -1
            }
            return 0
        }else{
            return -1
        }
    }
    
    func obtenerFavoritosDeRuta(nombreRuta:String)->[PuntoFavoritoCoreData]?{
        let comprueba = self.compruebaExistenciaRuta(nombreRuta)
        if  comprueba == 1{
            let favoritosEntidad = NSEntityDescription.entityForName("PuntoFavorito", inManagedObjectContext: self.managedObjectContext)
            let consulta = favoritosEntidad!.managedObjectModel.fetchRequestFromTemplateWithName("favoritosDeRuta", substitutionVariables: ["nombreConsulta":nombreRuta])
            do{
                let resultadoConsulta = try self.managedObjectContext.executeFetchRequest(consulta!)
                let numeroFavoritos = resultadoConsulta.count
                if numeroFavoritos > 0{
                    print ("Obtenemos \(resultadoConsulta.count) elementos")
                    return resultadoConsulta as? [PuntoFavoritoCoreData]
                }
            }catch let error as NSError {
                print("Error al obtener favoritos de la ruta \(nombreRuta): \(error.localizedDescription)")
                return nil
            }
            
        }
        //No existe la ruta nombreRuta
        return nil
    }
    //----------------------------------------------------------------------------------------------------------
    
    //Preparación de la vista de Realidad Aumentada-------------------------------------------------------------
    
    func arrancaRealidadAumentada(){
        //Comprobamos si el dispositivo tiene cámara y si la tiene, si tenemos una ruta activa
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let alerta = UIAlertController(title: "Escaneado no soportado", message: "Su dispositivo no está soportado. Utilice un dispositivo con cámara", preferredStyle: .Alert)
            let accionOK = UIAlertAction (title: "OK", style: .Default, handler: nil)
            alerta.addAction(accionOK)
            self.presentViewController(alerta, animated: true, completion: nil)
            
        }else if nombreRutaActual != ""{
            let controladorRA = ARViewController()
            controladorRA.debugEnabled = true
            controladorRA.dataSource = self
            controladorRA.maxDistance = 0
            controladorRA.maxVisibleAnnotations = 100
            controladorRA.maxVerticalLevel = 5
            controladorRA.headingSmoothingFactor = 0.05
            controladorRA.trackingManager.userDistanceFilter = 25
            controladorRA.trackingManager.reloadDistanceFilter = 75
        
            var annotationFavoritos: [ARAnnotation] = []
        
            let favoritos = obtenerFavoritosDeRuta(nombreRutaActual)
        
            for favorito in favoritos!{
                let anotacionRA = ARAnnotation()
                anotacionRA.title = favorito.nombreFavorito
                anotacionRA.location = CLLocation(latitude: CLLocationDegrees(favorito.latitudFavorito!), longitude: CLLocationDegrees(favorito.longitudFavorito!))
                annotationFavoritos.append(anotacionRA)
            }
        
            controladorRA.setAnnotations(annotationFavoritos)
            self.presentViewController(controladorRA, animated: true, completion: nil)
        }
    }
    
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    @IBAction func lanzarRA(sender: UIBarButtonItem) {
        self.arrancaRealidadAumentada()
    }
    
}


//Extension desde la que controlamos la información recibida
extension RutasViewController1: WCSessionDelegate {
    
}


