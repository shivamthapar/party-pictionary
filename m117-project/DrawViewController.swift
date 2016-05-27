//
//  ViewController.swift
//  DrawCanvas
//
//  Created by Andy Yu on 5/23/16.
//  Copyright © 2016 Hongseok (Andy) Yu. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    
    var isSwiping = false
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    
    var saved_image = [UIImage?]()
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isSwiping = false
        saved_image.append(self.mainImageView.image)
        if let touch = touches.first{
            lastPoint = touch.locationInView(mainImageView)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isSwiping = true;
        if let touch = touches.first{
            let currentPoint = touch.locationInView(mainImageView)
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            self.mainImageView.image?.drawInRect(CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height))
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y)
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),red, green, blue, opacity)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(!isSwiping) {
            UIGraphicsBeginImageContext(self.mainImageView.frame.size)
            self.mainImageView.image?.drawInRect(CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height))
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushWidth)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity)
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
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
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func viewDidLoad() {
        red   = (0.0/255.0)
        green = (0.0/255.0)
        blue  = (0.0/255.0)
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
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
    }
    
    @IBAction func reset(sender: UIButton) {
        self.mainImageView.image = nil
    }
    
    @IBAction func pencilPressed(sender: UIButton) {
        // which color index was selected?
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        // set RGB values
        (red, green, blue) = colors[index]
        
        // eraser
        if index == colors.count - 1 {
            opacity = 1.0
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
    }
}

