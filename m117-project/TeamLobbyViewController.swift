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
    
    let playerService = PlayerServiceManager()
    
    var players = [Player]()
    var playerViews = [PlayerDraggableView]()
    var selectedPlayerView: PlayerDraggableView? = nil
    var selectedPlayerIndex: Int? = nil
    
    var lobbyList = [String](count: 4, repeatedValue: "")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerService.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let numPlayers = playersContainer.numPlayers
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "countdownSegue") {
            if let svc = segue.destinationViewController as? CountdownViewController{
                svc.playerService = playerService
            }
            
        }
    }
    
    func addPlayer(deviceId: String) {
        
        let i = players.count
        let player = Player()
        player.state = .Connected
        player.id = deviceId
        players.append(player)
        
        
        let playerPosition = getPlayerInitPosition(i)
        let playerView = PlayerDraggableView(frame: CGRectMake(playerPosition.x, playerPosition.y, 50, 50))
//        if(deviceId == UIDevice.currentDevice().name){
//            playerView.myLabel.text = "me"
//        }
        playerView.myLabel.text = deviceId
//        if(deviceId == UIDevice.currentDevice().name){
//            let playerView = PlayerDraggableView(frame: CGRectMake(playerPosition.x, playerPosition.y, 50, 50))
//        } else {
//            let playerView = PlayerDraggableView(frame: CGRectMake(playerPosition.x, playerPosition.y, 50, 50), string: "me")
//        }
        playerView.initPos = playerView.centerCoordsFromOrigin(playerPosition)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TeamLobbyViewController.detectPanOnPlayer(_:)))
        playerView.gestureRecognizers = [panRecognizer]
        super.view.addSubview(playerView)
        playerViews.append(playerView)
    }
    
    func removeAllPlayers(){
        for playerView in playerViews {
            playerView.removeFromSuperview()
        }
        playerViews.removeAll()
        players.removeAll()
    }
    
    func getPlayerInitPosition(i: Int) -> CGPoint{
        let xOffset = playersContainer.frame.origin.x
        let yOffset = playersContainer.center.y
        let pointX = xOffset + CGFloat(i) * playersContainer.playerWidth + CGFloat(i+1) * playersContainer.gapBetweenPlayers
        let pointY = yOffset - playersContainer.playerWidth/2
        return CGPoint(x: pointX, y: pointY)
    }
    
    private func getPlayerTeamFromViewTeam(view: LockedInContainer, player: Player) -> Player.Team {
        switch view.team {
        case 1:
            return Player.Team.One
        case 2:
            return Player.Team.Two
        default:
            return Player.Team.NotAssigned
        }

    }
    
    private func getPlayerRoleFromViewRole(view: LockedInContainer, player: Player) -> Player.Role {
        switch view.role {
        case "guesser":
            return Player.Role.Guesser
        case "drawer":
            return Player.Role.Drawer
        default:
            return Player.Role.None
        }
        
    }
    
    func detectPanOnPlayer(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            let point = recognizer.locationInView(self.view)
            if let touchedLock = lockTouched(point) {
                if !lockContainsAPlayer(touchedLock){
                    if let playerIndex = selectedPlayerIndex {
                        let playerView = playerViews[playerIndex]
                        playerView.moveToPoint(touchedLock.center, duration:0.2)
                        playerView.lastLocation = playerView.center
                        
                        let player = players[playerIndex]
                        player.team = getPlayerTeamFromViewTeam(touchedLock, player: player)
                        player.role = getPlayerRoleFromViewRole(touchedLock, player: player)
                    }
                }
                else {
                    print("lock contains a player!")
                    if let playerIndex = selectedPlayerIndex {
                        let playerView = playerViews[playerIndex]
                        if let initPos = playerView.initPos {
                            playerView.moveToPoint(initPos, duration:0.5)
                        } else {
                            playerView.moveToPoint(playersContainer.center, duration: 0.5)
                        }
                        
                        let player = players[playerIndex]
                        player.team = .NotAssigned
                        player.role = .None
                    }
                }
            } else {
                if let playerIndex = selectedPlayerIndex {
                    let playerView = playerViews[playerIndex]
                    if let initPos = playerView.initPos {
                        playerView.moveToPoint(initPos, duration:0.5)
                    } else {
                        playerView.moveToPoint(playersContainer.center, duration: 0.5)
                    }
                    
                    let player = players[playerIndex]
                    player.team = .NotAssigned
                    player.role = .None
                }
                
            }
        default:
            if let playerView = recognizer.view as? PlayerDraggableView {
                let translation = recognizer.translationInView(self.view)
                playerView.center = CGPointMake(playerView.lastLocation.x + translation.x, playerView.lastLocation.y + translation.y)
            }
            
            let point = recognizer.locationInView(self.view)
            if lockTouched(point) == nil {
                if let index = selectedPlayerIndex{
                    let player = players[index]
                    player.team = .NotAssigned
                    player.role = .None
                }
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
    
    func lockContainsPlayer(lock: LockedInContainer, playerView: PlayerDraggableView, player: Player) -> Bool {
        if CGRectContainsRect(lock.frame, playerView.frame){
            if player.team != .NotAssigned && player.role != .None {
                return true
            }
        }
        return false
    }
    
    func lockContainsAPlayer(lock: LockedInContainer) -> Bool {
        for (index,playerView) in playerViews.enumerate() {
            if lockContainsPlayer(lock, playerView: playerView, player: players[index]) {
                return true
            }
        }
        return false
    }
    
    private func getIndexOfPlayerTouched(point: CGPoint) -> Int? {
        var playerIndex: Int? = nil
        for (index, playerView) in playerViews.enumerate() {
            if CGRectContainsPoint(playerView.frame, point) {
                playerIndex = index
            }
        }
        return playerIndex
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self.view)
            if let indexOfTouchedPlayer = getIndexOfPlayerTouched(point) {
                let playerView = playerViews[indexOfTouchedPlayer]
                self.view.bringSubviewToFront(playerView)
                playerView.lastLocation = playerView.center
                selectedPlayerIndex = indexOfTouchedPlayer
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TeamLobbyViewController: PlayerServiceManagerDelegate{
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            if connectedDevices.count == 1 { // first pair - self and 2nd device
                if connectedDevices[0] < UIDevice.currentDevice().name {
                    if self.lobbyList[0] == "" && self.lobbyList[1] == "" {
                        self.lobbyList[0] = connectedDevices[0]
                        self.lobbyList[1] = UIDevice.currentDevice().name
                    }
                }
            }
            else if connectedDevices.count == 2 { // 3rd device
                if self.lobbyList.count != 0 {  // original pair does this (hopefully)
                    if self.lobbyList[2] == "" {
                        self.lobbyList[2] = connectedDevices[1]
                        let message:NSDictionary = ["lobbyList": self.lobbyList.joinWithSeparator(",")]
                        self.playerService.sendMessage(message)
                    }
                }
            }
            else if connectedDevices.count == 3 { // 4th device
                if self.lobbyList.count != 0 {  // original pair does this (hopefully)
                    if self.lobbyList[3] == "" {
                        self.lobbyList[3] = connectedDevices[2]
                        let message:NSDictionary = ["lobbyList": self.lobbyList.joinWithSeparator(",")]
                        self.playerService.sendMessage(message)
                    }
                }
            }
//            for connectedDevice in connectedDevices{
//                self.addPlayer(connectedDevice)
//            }
        }
    }
    
    func messageReceived(manager: PlayerServiceManager, message: NSDictionary) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            NSLog("%@", "messageReceived")
            if let lobby_string = message["lobbyList"] {
                self.lobbyList = lobby_string.componentsSeparatedByString(",")
                self.removeAllPlayers()
                for id in self.lobbyList {
                    if id != "" {
                        self.addPlayer(id)
                    }
                }
            }
        }
    }
}

