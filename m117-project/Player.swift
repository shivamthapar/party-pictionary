//
//  PlayerTile.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/23/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import Foundation

class Player {
    var playerNumber = 0
    var id: String? = nil
    var ready = false
    var state = State.Disconnected
    var team = Team.NotAssigned {
        didSet {
            print(team)
        }
    }
    var role = Role.None {
        didSet {
            print(role)
        }
    }
    
    
    enum State {
        case Disconnected
        case Connected
    }
    
    enum Team {
        case One
        case Two
        case NotAssigned
    }
    
    enum Role {
        case Drawer
        case Guesser
        case None
    }
    
    
}