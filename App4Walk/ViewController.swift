//
//  ViewController.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 11/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //Contexto CoreData
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //ManagedObjectContext definido en AppDelegate -- Utilizamos el delegado
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MenuARutas" {
            if let controller = segue.destinationViewController as? UINavigationController {
                let rutas = controller.topViewController as! RutasViewController1
                rutas.managedObjectContext = self.managedObjectContext
            }
        }
        
    }


}

