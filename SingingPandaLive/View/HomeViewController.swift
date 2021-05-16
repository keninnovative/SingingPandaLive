//
//  ViewController.swift
//  SingingPandaLive
//
//  Created by Ken Nyame on 5/15/21.
//

import UIKit
import OpenTok


class HomeViewController: UIViewController {
    
    var kSessionId = "1_MX40NzIyOTYzNH5-MTYyMTEzNTQyMDk0Nn4wRFVUUSt0UXNORWJmcTdKTEQrcFRQRWJ-fg"
    var kToken = "T1==cGFydG5lcl9pZD00NzIyOTYzNCZzaWc9YWFlNDExMDBlZjFhNjIzMGJmODE5OGM1ZWM5MTNlMTc1ZjQ0MjRiYzpzZXNzaW9uX2lkPTFfTVg0ME56SXlPVFl6Tkg1LU1UWXlNVEV6TlRReU1EazBObjR3UkZWVVVTdDBVWE5PUldKbWNUZEtURVFyY0ZSUVJXSi1mZyZjcmVhdGVfdGltZT0xNjIxMTM1NDMzJm5vbmNlPTAuNDUwMTUxMzIyMjUzOTIyNCZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNjIxMTU3MDMyJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        connectToAnOpenTokSession()

    }
    
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: OpenTokConstants.apiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
}

extension HomeViewController:OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
            return
        }

        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }

        guard let publisherView = publisher.view else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        //publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
        view.addSubview(publisherView)
    }
    func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the OpenTok session.")
    }
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")
        
        subscriber = OTSubscriber(stream: stream, delegate: self)
        guard let subscriber = subscriber else {
            return
        }

        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }

        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
    
}

extension HomeViewController:OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

extension HomeViewController:OTSubscriberDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
    
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
}

