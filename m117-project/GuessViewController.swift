//
//  GuessViewController.swift
//  m117-project
//
//  Created by Andy Yu on 6/1/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit


class GuessViewController: UIViewController {
    
    // Bluetooth
    var bluetoothService: PlayerServiceManager!
    
    var other_isSwiping = false
    var otherLastPoint = CGPoint.zero
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    
    var saved_image = [UIImage?]()
    
    var my_team = -1
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]
    
    func drawLine(from: CGPoint, to: CGPoint) {
        UIGraphicsBeginImageContext(self.mainImageView.frame.size)
        self.mainImageView.image?.drawInRect(CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height))
        CGContextMoveToPoint(UIGraphicsGetCurrentContext()!, to.x, to.y)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext()!, from.x, from.y)
        CGContextSetLineCap(UIGraphicsGetCurrentContext()!, CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext()!, brushWidth)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext()!,red, green, blue, opacity)
        CGContextStrokePath(UIGraphicsGetCurrentContext()!)
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    override func viewDidLoad() {
        red   = (0.0/255.0)
        green = (0.0/255.0)
        blue  = (0.0/255.0)
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.bluetoothService.delegate = self
        winLab.hidden = true;
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        winLab.hidden = true
        textField.endEditing(true)
    }
    
    @IBAction func guess(sender: UIButton) {
        if textField.text == "dolphin" {
            winLab.text = "Correct!"
            winLab.hidden = false;
            let wintionary: NSDictionary = ["win": my_team]
            bluetoothService.sendMessage(wintionary)
        }
        else {
            winLab.text = "False! Loser HA"
            winLab.hidden = false;
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var winLab: UILabel!
}

extension GuessViewController: PlayerServiceManagerDelegate{
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            // do nothing
        }
    }
    
    func messageReceived(manager: PlayerServiceManager, message: NSDictionary) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            // message
            if let winningTeam = message["win"] {
                self.winLab.text = "Team \(winningTeam) won!"
                self.winLab.hidden = false
            }
            
            if let team = message["team"] {
                if team as! Int == self.my_team {
                    print(message)
                    if let point = message["newPoint"] {
                        self.other_isSwiping = true
                        self.otherLastPoint = point.CGPointValue()
                        self.saved_image.append(self.mainImageView.image)
                    }
                    else if let point = message["drawPoint"] {
                        self.drawLine(self.otherLastPoint, to: point.CGPointValue())
                        self.otherLastPoint = point.CGPointValue()
                    }
                    else if let point = message["endPoint"] {
                        self.other_isSwiping = false
                        self.drawLine(self.otherLastPoint, to: point.CGPointValue())
                    }
                    else if message["undo"] != nil {
                        if let image = self.saved_image.popLast() {
                            self.mainImageView.image = image
                        }
                    }
                    else if message["reset"] != nil {
                        self.mainImageView.image = nil
                    }
                    else if message["settings"] != nil {
                        self.red = message["red"] as! CGFloat
                        self.green = message["green"] as! CGFloat
                        self.blue = message["blue"] as! CGFloat
                        self.opacity = message["opacity"] as! CGFloat
                        self.brushWidth = message["brush"] as! CGFloat
                    }
                }
            }
            
        }
    }
    
}
