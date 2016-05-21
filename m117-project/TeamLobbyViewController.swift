//
//  ViewController.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/19/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import UIKit

class TeamLobbyViewController: UIViewController {
    
    @IBOutlet weak var playersContainer: PlayerDraggableContainer!
    @IBOutlet weak var p1Lock: LockedInContainer!
    @IBOutlet weak var p2Lock: LockedInContainer!
    @IBOutlet weak var p3Lock: LockedInContainer!
    @IBOutlet weak var p4Lock: LockedInContainer!
    
    var players = [PlayerDraggableView]()
    var selectedPlayer: PlayerDraggableView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let numPlayers = playersContainer.numPlayers
        
        for i in 0..<numPlayers {
            let playerPosition = getPlayerInitPosition(i)
            let playerView = PlayerDraggableView(frame: CGRectMake(playerPosition.x, playerPosition.y, 50, 50))
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TeamLobbyViewController.detectPanOnPlayer(_:)))
            playerView.gestureRecognizers = [panRecognizer]
            super.view.addSubview(playerView)
            players.append(playerView)
        }
    }
    
    func getPlayerInitPosition(i: Int) -> CGPoint{
        let xOffset = playersContainer.frame.origin.x
        let yOffset = playersContainer.center.y
        let pointX = xOffset + CGFloat(i) * playersContainer.playerWidth + CGFloat(i+1) * playersContainer.gapBetweenPlayers
        let pointY = yOffset - playersContainer.playerWidth/2
        return CGPoint(x: pointX, y: pointY)
    }
    
    func detectPanOnPlayer(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            print("touch ended")
            let point = recognizer.locationInView(self.view)
            if let touchedLock = lockTouched(point) {
                if let player = selectedPlayer {
                    player.moveToPoint(touchedLock.center, duration:0.2)
                    player.lastLocation = player.center
                }
            } else {
                if !CGRectContainsPoint(playersContainer.frame, point) {
                    if let player = selectedPlayer {
                        player.moveToPoint(playersContainer.center, duration:0.5)
                    }
                }
            }
        default:
            if let player = recognizer.view as? PlayerDraggableView {
                selectedPlayer = player
                let translation = recognizer.translationInView(self.view)
                player.center = CGPointMake(player.lastLocation.x + translation.x, player.lastLocation.y + translation.y)
            }
        }
    }
    
    func lockTouched(point: CGPoint) -> LockedInContainer? {
        var lock: LockedInContainer? = nil
        if CGRectContainsPoint(p1Lock.frame, point) {
            lock = p1Lock
        }
        else if CGRectContainsPoint(p2Lock.frame, point) {
            lock = p2Lock
        }
        else if CGRectContainsPoint(p3Lock.frame, point) {
            lock = p3Lock
        }
        else if CGRectContainsPoint(p4Lock.frame, point) {
            lock = p4Lock
        }
        return lock
    }
    
    private func playerTouched(point: CGPoint) -> PlayerDraggableView? {
        var touchedPlayer: PlayerDraggableView? = nil
        for player in players {
            if CGRectContainsPoint(player.frame, point) {
                touchedPlayer = player
            }
        }
        return touchedPlayer
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self.view)
            if let touchedPlayer = playerTouched(point) {
                self.view.bringSubviewToFront(touchedPlayer)
                touchedPlayer.lastLocation = touchedPlayer.center
                selectedPlayer = touchedPlayer
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

