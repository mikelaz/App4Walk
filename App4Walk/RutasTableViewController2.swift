//
//  RutasTableViewController2.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 20/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreData

protocol RutasTableViewController2Delegate{
    func actualizacionRutasDelegatedMethod(moc: NSManagedObjectContext, nombreRutaSeleccionada:String)
}

class RutasTableViewController2: UITableViewController {
    
    var fetchedResultsController : NSFetchedResultsController!
    var managedObjectContext: NSManagedObjectContext!
    
    var indexSeleccionado: NSIndexPath!
    var nombreRutaSeleccionada: String!
    
    var delegate: RutasTableViewController2Delegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1
        let fetchRequest = NSFetchRequest(entityName: "Ruta")
        let sortDescriptor = NSSortDescriptor(key: "nombreRuta", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //2
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        //3
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        fetchedResultsController.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath) as! RutasTableViewCell

        self.configureCell(cell, indexPath: indexPath)

        return cell
    }

    
    func configureCell(cell: RutasTableViewCell, indexPath: NSIndexPath) {
        let ruta = fetchedResultsController.objectAtIndexPath(indexPath) as! RutaCoreData
        cell.imagenCelda = nil
        cell.nombreRuta.text = ruta.nombreRuta
        if ruta.nombreRuta == nombreRutaSeleccionada{
            cell.accessoryType = .Checkmark
            indexSeleccionado = indexPath
        }else{
            cell.accessoryType = .None
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ruta = fetchedResultsController.objectAtIndexPath(indexPath) as! RutaCoreData
        nombreRutaSeleccionada = ruta.nombreRuta
        indexSeleccionado = indexPath
        //llamada a función para cambiar de ruta activa en la vista del mapa
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! RutasTableViewCell
        cell.accessoryType = .Checkmark
        tableView.reloadData()
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }



    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            //Si borramos la ruta seleccionada, establecemos el nombreDeRutaSeleccionada a ""
            if indexSeleccionado != nil && indexPath == indexSeleccionado{
                    indexSeleccionado = nil
                    nombreRutaSeleccionada = ""
            }
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try context.save()
            } catch {
                print("Error al eliminar el elemento de la lista")
                abort()
            }
        }
    }

    //Función que envía los cambios realizados en la tabla y en el contexto CoreData
    @IBAction func enviarCambiosAMapa(sender: UIBarButtonItem) {
        self.delegate?.actualizacionRutasDelegatedMethod(self.managedObjectContext, nombreRutaSeleccionada: nombreRutaSeleccionada)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RutasTableViewController2: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! RutasTableViewCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type:NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            tableView.insertSections(indexSet,withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet,withRowAnimation: .Automatic)
        default :
            break
        }
    }
}
