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
        
        var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
        self.gestureRecognizers = [panRecognizer]
        
        let blueValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenValue = CGFloat(Int(arc4random() % 255)) / 255.0
        let redValue = CGFloat(Int(arc4random() % 255)) / 255.0
        
        self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func detectPan(recognizer: UIPanGestureRecognizer) {
        var translation = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.superview?.bringSubviewToFront(self)
        lastLocation = self.center
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
//
//class PlayerDraggableContainer: UIView {
//    
//    var numPlayers: Int = 4
//    var playerWidth: CGFloat = 40.0
//    var width: CGFloat {
//        return 6.5 * playerWidth
//    }
//    
//    private func pathForContainer() -> UIBezierPath {
//        return UIBezierPath(rect: CGRect(x: playerWidth*0.5, y: CGFloat(100.0), width: width, height: CGFloat(20.0)))
//    }
//    
//    override func drawRect(rect: CGRect) {
//        UIColor.blueColor().set()
//        pathForContainer().fill()
//    }
//}
