//
//  ViewController.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/19/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class NewTeamLobbyViewController: UIViewController {
    
    var my_team = -1    // 1 is team 1, 2 is team 2, -1 is unassigned
    var my_role = -1    // 1 is drawer, 2 is guesser, -1 is unassigned
    var ready_pressed = false
    var players = [String: [String: Int]]()
    var lights = 0 {
        didSet {
            for i in 0 ..< 4 {
                lightArray[i].image = UIImage(named: "empty_light")
            }
            for i in 0 ..< lights {
                lightArray[i].image = UIImage(named: "light")
            }
            if lights == 2 {
                 self.performSegueWithIdentifier("countdownSegue", sender: nil)
            }
        }
    }
    var lightArray = [UIImageView]()
    var playerService : PlayerServiceManager! // bluetooth
    
    @IBOutlet weak var teamSlider: UISlider!
    @IBOutlet weak var roleSlider: UISlider!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBAction func teamSliderValueChanged(sender: UISlider) {
        let value = roundSliderValue(sender.value)
        if value == 0 {
            my_team = 1
        }
        else {
            my_team = 2
        }
        sender.setValue(value, animated: true)
    }
    @IBAction func roleSliderValueChanged(sender: UISlider) {
        let value = roundSliderValue(sender.value)
        if value == 0 {
            my_role = 1
        }
        else {
            my_role = 2
        }
        sender.setValue(roundSliderValue(sender.value), animated: true)
    }
    
    @IBOutlet weak var light1: UIImageView!
    @IBOutlet weak var light2: UIImageView!
    @IBOutlet weak var light3: UIImageView!
    @IBOutlet weak var light4: UIImageView!
    
    @IBAction func readyButtonPressed(sender: UIButton) {
        for (_, value) in players {
            if my_role == value["role"] && my_team == value["team"] {
                warningLabel.hidden = false
                
                return
            }
        }
        if !ready_pressed {
            if my_team == -1 || my_role == -1 {
                return
            }
            // change color of button?
            let message:NSDictionary = ["player_ready": UIDevice.currentDevice().name, "team": my_team, "role": my_role]
            self.playerService.sendMessage(message)
            lights += 1
            ready_pressed = true
        }
        else {
            // change color of button to original state
            let message:NSDictionary = ["player_unready": UIDevice.currentDevice().name, "team": -1, "role": -1]
            self.playerService.sendMessage(message)
            self.lights -= 1
            ready_pressed = false
        }
    }

    func roundSliderValue(x: Float) -> Float {
        if(x < 0.5) {
            return 0
        }
        return 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "lobby_bg")?.drawInRect(self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        lightArray = [light1, light2, light3, light4]
        
        warningLabel.hidden = true
        self.playerService.delegate = self
        // Do any additional1 setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "countdownSegue") {
            if let svc = segue.destinationViewController as? CountdownViewController{
                svc.playerService = playerService
                svc.team = my_team
                svc.role = my_role
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        warningLabel.hidden = true
    }
}


extension NewTeamLobbyViewController: PlayerServiceManagerDelegate{
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
        }
    }


    func messageReceived(manager: PlayerServiceManager, message: NSDictionary) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if let name = message["player_ready"] {
                self.lights += 1
                self.players[name as! String] = ["team": message["team"] as! Int, "role": message["role"] as! Int]
            }
            if let name = message["player_unready"] {
                self.lights -= 1
                self.players[name as! String] = ["team": -1, "role": -1]
            }
            print(self.lights)
        }
    }
}
