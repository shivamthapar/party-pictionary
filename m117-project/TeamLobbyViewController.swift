//
//  ViewController.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/19/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class TeamLobbyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let halfSizeOfView = 25.0
        let gapBetweenPlayers = 3 * halfSizeOfView
        let maxViews = 4
        let insetSize = CGRectInset(self.view.bounds, CGFloat(Int(2*halfSizeOfView)), CGFloat(Int(2*halfSizeOfView))).size
        
        for i in 0..<maxViews {
            var pointX = CGFloat(Double(i) * gapBetweenPlayers + 40)
            var pointY = self.view.center.y
            
            var newView = PlayerDraggableView(frame: CGRectMake(pointX, pointY, 50, 50))
            self.view.addSubview(newView)
        }
        
//        var newView = PlayerDraggableContainer()
//        self.view.addSubview(newView)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

