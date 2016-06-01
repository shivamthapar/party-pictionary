//
//  ViewController.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/19/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    var playerService: PlayerServiceManager!
    var team = -1
    var role = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(CountdownViewController.timerComplete), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "drawSegue") {
            if let svc = segue.destinationViewController as? DrawViewController{
                svc.bluetoothService = playerService
                svc.my_team = team
            }
            
        }
        if (segue.identifier == "guessSegue") {
            if let svc = segue.destinationViewController as? GuessViewController{
                svc.bluetoothService = playerService
                svc.my_team = team
            }
            
        }
    }
    
    func timerComplete() {
        if(role == 1) {
            self.performSegueWithIdentifier("drawSegue", sender: nil)
        }
        else if(role == 2) {
            self.performSegueWithIdentifier("guessSegue", sender: nil)
        }
    }
    
}
