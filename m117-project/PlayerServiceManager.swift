//
//  PlayerServiceManager.swift
//  m117-project
//
//  Created by Shivam Thapar on 5/25/16.
//  Copyright © 2016 Shivam Thapar. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol PlayerServiceManagerDelegate {
    func connectedDevicesChanged(manager: PlayerServiceManager, connectedDevices: [String])
    func messageReceived(manager: PlayerServiceManager, message: NSDictionary)
}

class PlayerServiceManager : NSObject {
    
    private let PlayerServiceType = "example-player"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    var delegate: PlayerServiceManagerDelegate?
    
    func sendMessage(message: NSDictionary){
        //NSLog("%@", "sendMessage: \(message)")
        if session.connectedPeers.count > 0 {
            //var error: NSError?
            do {
                try self.session.sendData(NSKeyedArchiver.archivedDataWithRootObject(message), toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch {
                NSLog("%@", "\(error)")
            }
        }
    }
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: PlayerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: PlayerServiceType)

        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self){
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        //default: return "Unknown"
        }
    }
}

extension PlayerServiceManager: MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        //NSLog("%@", "didReceiveData: \(data)")
        self.delegate?.messageReceived(self, message: NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}

extension PlayerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer: \(peerID) \(context)")
        invitationHandler(true, self.session)
    }
}

extension PlayerServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}
