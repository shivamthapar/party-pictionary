//
//  PlayerDraggableView.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/20/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class PlayerDraggableView: UIView {
    
    var myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    var initPos: CGPoint? = nil
    
    var lastLocation:CGPoint = CGPointMake(0,0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
        
        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        
        self.addSubview(myLabel)
    }
//    
//    init(frame: CGRect, string: String){
//        myLabel.text = "Me"
//        super.init(frame: frame)
//        
//        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
//        
//        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
//        
//        self.addSubview(myLabel)
//    }
    
    func moveToPoint(point: CGPoint, duration: NSTimeInterval) {
        var newFrame = self.frame
        newFrame.origin.x = point.x - self.frame.width/2
        newFrame.origin.y = point.y - self.frame.height/2
        
        UIView.animateWithDuration(duration, animations: {
            self.frame = newFrame
        })
    }
    
    func centerCoordsFromOrigin(origin: CGPoint) -> CGPoint {
        let centerX = origin.x + self.frame.width/2
        let centerY = origin.y + self.frame.height/2
        return CGPoint(x: centerX, y: centerY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
}

@IBDesignable
class PlayerDraggableContainer: UIView {
    
    @IBInspectable
    var numPlayers: Int = 4
    
    var playerWidth: CGFloat{
        return self.bounds.width/6.5
    }
    
    var gapBetweenPlayers: CGFloat {
        return self.bounds.width/13.0
    }
    
    override func drawRect(rect: CGRect) {
    }
}

@IBDesignable
class LockedInContainer: UIView {
    
    @IBInspectable
    var team: Int = 0 // should be set to 1 or 2 in IB
    
    @IBInspectable
    var role: String = "none" // should be set to "guesser" or "drawer" in IB
    
    
}
