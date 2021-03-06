//
//  Messenger.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol Messenger {
    func connect(_ streamId: Int)
    func disconnect(_ streamId: Int)
    func send(_ message: Message, streamId: Int)
    func receive(_ handler: (_ message: Message)->())
}

class MessengerFactory: NSObject {
//    class func getMessenger(_ name: String) -> Messenger? {
//        if name == "pubnub" {
//            return PubNubMessenger()
//        }
//        return nil
//    }
}
