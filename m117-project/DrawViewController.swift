//
//  ViewController.swift
//  DrawCanvas
//
//  Created by Andy Yu on 5/23/16.
//  Copyright © 2016 Hongseok (Andy) Yu. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    
     // Bluetooth
    var bluetoothService: PlayerServiceManager!
    
    var isSwiping = false
    var other_isSwiping = false
    var lastPoint = CGPoint.zero
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if word.hidden == false {
            return
        }
        isSwiping = false
        saved_image.append(self.mainImageView.image)
        if let touch = touches.first{
            lastPoint = touch.locationInView(mainImageView)
        }
        let dictionary:NSDictionary = ["newPoint": NSValue(CGPoint: lastPoint), "team": my_team]
        bluetoothService.sendMessage(dictionary)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if word.hidden == false {
            return
        }
        isSwiping = true;
        if let touch = touches.first{
            let currentPoint = touch.locationInView(mainImageView)
            drawLine(currentPoint, to: lastPoint)
            let dictionary = ["drawPoint": NSValue(CGPoint: currentPoint), "team": my_team]
            bluetoothService.sendMessage(dictionary)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if word.hidden == false {
            word.hidden = true
            return
        }
        if(!isSwiping) {
            drawLine(lastPoint, to: lastPoint)
            let dictionary:NSDictionary = ["lastPoint": NSValue(CGPoint: lastPoint), "team": my_team]
            bluetoothService.sendMessage(dictionary)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingsViewController = segue.destinationViewController as! SettingsDrawViewController
        settingsViewController.delegate = self
        settingsViewController.brush = brushWidth
        settingsViewController.opacity = opacity
        settingsViewController.red = red
        settingsViewController.green = green
        settingsViewController.blue = blue
    }
    
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func viewDidLoad() {
        red   = (0.0/255.0)
        green = (0.0/255.0)
        blue  = (0.0/255.0)
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.bluetoothService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func undo(sender: UIButton) {
        if let image = saved_image.popLast() {
            self.mainImageView.image = image
        }
        let dictionary:NSDictionary = ["undo": "_", "team": my_team]
        bluetoothService.sendMessage(dictionary)
    }
    
    @IBAction func reset(sender: UIButton) {
        self.mainImageView.image = nil
        let dictionary:NSDictionary = ["reset": "_", "team": my_team]
        bluetoothService.sendMessage(dictionary)
    }
    
    @IBAction func pencilPressed(sender: UIButton) {
        // which color index was selected?
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        // set RGB values
        (red, green, blue) = colors[index]
        let dictionary:NSDictionary = ["settings": 1, "red": red, "green": green, "blue": blue, "opacity": opacity, "brush": brushWidth, "team": my_team]
        bluetoothService.sendMessage(dictionary)
        
        // eraser
        if index == colors.count - 1 {
            opacity = 1.0
            let dictionary:NSDictionary = ["erase": "_", "team": my_team]
            bluetoothService.sendMessage(dictionary)
        }
    }
}

extension DrawViewController: SettingsDrawViewControllerDelegate {
    func settingsDrawViewControllerFinished(settingsDrawViewController: SettingsDrawViewController) {
        self.brushWidth = settingsDrawViewController.brush
        self.opacity = settingsDrawViewController.opacity
        self.red = settingsDrawViewController.red
        self.green = settingsDrawViewController.green
        self.blue = settingsDrawViewController.blue
        let dictionary:NSDictionary = ["settings": 1, "red": red, "green": green, "blue": blue, "opacity": opacity, "brush": brushWidth, "team": my_team]
        bluetoothService.sendMessage(dictionary)
    }
}

extension DrawViewController: PlayerServiceManagerDelegate{
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            // do nothing
        }
    }
    
    func messageReceived(manager: PlayerServiceManager, message: NSDictionary) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            // message
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

