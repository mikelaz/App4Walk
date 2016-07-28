//
//  EventosTableViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 26/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import MapKit

class EventosTableViewController: UITableViewController {
    
    var tipoEvento: [String] = []
    var secciones: [String:[Evento]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        cargaElementosJSON()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return tipoEvento.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //Devolvemos el número de elementos que el diccionario tiene para un determinado tipo de evento
        return secciones[tipoEvento[section]]!.count
    }
    
    //Función necesaria para que aparezca el titulo de la sección
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.tipoEvento[section]
        
    }
    
    //Función para configurar el encabezado de la sección
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 47/255, green: 99/255, blue: 209/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        header.alpha = 1 //make the header transparent
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCellWithIdentifier("CeldaEvento", forIndexPath: indexPath) as! EventosTableViewCell
        //Recuperamos el array de elementos de un determinado tipo de evento (sección). Utilizamos el nombre del tipo de evento para filtrar el diccionario
        let eventosTipo = secciones[tipoEvento[indexPath.section]]
        //Obtenemos el evento nº X (row) del array para el tipo seleccionado (sección)
        let evento = eventosTipo![indexPath.row]
        
        celda.nombreEvento.text = evento.nombreEvento
        celda.nombreEvento.numberOfLines = 2

        return celda
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetalleEvento" {
            if let controller = segue.destinationViewController as? DetalleEventoViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let eventosTipo = secciones[tipoEvento[indexPath.section]]
                    let evento = eventosTipo![indexPath.row]
                    controller.nombre = evento.nombreEvento
                    controller.tipo = evento.tipoEvento
                    controller.municipio = evento.municipioEvento
                    controller.lugar = evento.lugarEvento
                    controller.coordenadas = evento.coordenadasEvento
                    controller.urlInformacion = evento.enlaceEvento
                    controller.fecha = evento.fechaEvento
                }
            }

        }
    }
    
    @IBAction func salirEventos(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cargaElementosJSON(){

        var municipio: String!
        var lugar: String!
        var fecha: String!
        var coordenadas: CLLocationCoordinate2D?
        
        if let datos = descargaConvierteJSON(){
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(datos, options: NSJSONReadingOptions.MutableLeaves)
                let dico1 = json as! NSDictionary
                let dico2 = dico1["Eventos"] as? [NSDictionary]
                if dico2 != nil{
                    for evento in (dico2?.enumerate())!{
                        //enumerate nos devuelve una tupla con (index,valor), en este caso (index,diccionario)
                        let nombre = dico2![evento.index]["documentName"] as! String
                        let tipo = dico2![evento.index]["eventType"] as! String
                        if let municipality = dico2![evento.index]["municipality"] as? String{
                            municipio = municipality
                        }else{
                            //Campo municipio no existe
                            municipio = "N/A"
                        }
                        if let placename = dico2![evento.index]["placename"] as? String{
                            lugar = placename
                        }else{
                            //Campo lugar no existe
                            lugar = "N/A"
                        }
                        if let startDate = dico2![evento.index]["eventStartDate"] as? String{
                            fecha = startDate
                        }else{
                            //Campo fecha no existe
                            fecha = "N/A"
                        }
                        let enlace = NSURL(string: dico2![evento.index]["friendlyUrl"] as! String)
                        if let latitudLongitud = dico2![evento.index]["latitudelongitude"] as? String{
                            //latitudelongitude contiene un string con la lat y long separadas por una coma
                            //realizamos un split para separarlo en lat por un lado y long por otro
                            let arrayCoordenadas = latitudLongitud.componentsSeparatedByString(",")
                            coordenadas = CLLocationCoordinate2D(latitude: CLLocationDegrees(arrayCoordenadas[0])!, longitude: CLLocationDegrees(arrayCoordenadas[1])!)
                        }else{
                            coordenadas = nil
                        }
                        
                        //Vamos generando un diccionario con los tipos de eventos y sus correspondientes eventos para utilizarlo como base para la generación de secciones en la tabla
                        //Si no existe sección para el tipo, generamos una nueva sección y añadimos el tipo a la tabala de tipoEvento
                        if self.secciones.indexForKey(tipo) == nil {
                            self.secciones[tipo] = [Evento(nombreEvento: nombre, tipoEvento: tipo, municipioEvento: municipio, lugarEvento: lugar, fechaEvento: fecha, enlaceEvento: enlace!, coordenadasEvento: coordenadas)]
                            self.tipoEvento.append(tipo)
                        }
                        else {
                            self.secciones[tipo]!.append(Evento(nombreEvento: nombre, tipoEvento: tipo, municipioEvento: municipio, lugarEvento: lugar, fechaEvento: fecha, enlaceEvento: enlace!, coordenadasEvento: coordenadas))
                        }

                    }
                }
            }catch{
                print("Error en el parseo del JSON")
            }
        }else{
            print("Error en la descarga")
        }

    }
    
    func descargaConvierteJSON()->NSData?{
        //Utilizamos Servicio Web de que entrega JSON con la agenda de cultura de Euskadi
        //El JSON facilitado no cuenta con el formato esperado y es por ello que es necesaria esta función que modifica el fichero descargado para 
        //que pueda ser parseado por la clase NSJSONSerialization
        //El fichero original está en ASCII
        let myURLString = "http://opendata.euskadi.eus/contenidos/ds_eventos/agenda_cultura_euskadi/es_kultura/adjuntos/kulturklik.json"
        let myURL = NSURL(string: myURLString)
            
        do {
            var myHTMLString = try String(contentsOfURL: myURL!, encoding: NSASCIIStringEncoding)
                
            let prefijo = myHTMLString.rangeOfString("jsonCallback(")
            let sufijo = myHTMLString.rangeOfString(");")
            if prefijo != nil && sufijo != nil{
                //primero modificamos el sufijo y después cambiamos el prefijo para que no cambie el índice del prefijo
                myHTMLString.replaceRange(sufijo!, with: "}")
                myHTMLString.replaceRange(prefijo!, with: "{ \"Eventos\":")
                let myNSString = myHTMLString as NSString
                let data: NSData = myNSString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
                return data
            }else{
                print("Prefijo o sufijo nulos")
                return nil
            }
        }catch {
            print("Error descargando el fichero JSON")
            return nil
        }
        
    }

}
