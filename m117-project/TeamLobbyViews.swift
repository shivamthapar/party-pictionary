//
//  PlayerDraggableView.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/20/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class PlayerDraggableView: UIView {
    
    var lastLocation:CGPoint = CGPointMake(0,0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
        
        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    func moveToPoint(point: CGPoint, duration: NSTimeInterval) {
        var newFrame = self.frame
        newFrame.origin.x = point.x - self.frame.width/2
        newFrame.origin.y = point.y - self.frame.height/2
        
        UIView.animateWithDuration(duration, animations: {
            self.frame = newFrame
        })
        
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
    
}
