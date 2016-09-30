//
//  ViewController.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/19/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class BluetoothConnectionViewController: UIViewController {
    
    let playerService = PlayerServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "searching")?.drawInRect(self.view.bounds)
        
        playerService.delegate = self   // bluetooth
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "teamLobbySegue") {
            if let svc = segue.destinationViewController as? NewTeamLobbyViewController{
                svc.playerService = playerService
            }
        }
    }
    
}

extension BluetoothConnectionViewController: PlayerServiceManagerDelegate{
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("teamLobbySegue", sender: nil)
        }
    }
    func messageReceived(manager: PlayerServiceManager, message: NSDictionary) {
    }
}
