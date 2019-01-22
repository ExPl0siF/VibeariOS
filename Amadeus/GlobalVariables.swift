//
//  GlobalVariables.swift
//  
//
//  Created by Theo Caselli on 17/05/2017.
//
//

import Foundation
import AVFoundation
import Alamofire

var APIURL = "http://vibearpi.local/"
//let APIURL = "http://192.168.2.1/"

let SOUNDURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sound.wav")
let SOUNDURL2: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sound2.wav")

var manager: Alamofire.SessionManager!

var NIGHTMODE = true

var XACCESSTOKEN = "NIL"

class GenericSound
{
    var id: String
    var name: String
    var notification: Bool
    
    init(soundName: String, soundID: String, notification: Bool)
    {
        self.id = soundID
        self.name = soundName
        self.notification = notification
    }
}

class GenericMic
{
    var id: String
    var name: String
    var battery: Int
    var state: Int
    var configured: Bool
    
    init(micName: String, micID: String, battery: Int, state: Int, configured: Bool)
    {
        self.id = micID
        self.name = micName
        self.battery = battery
        self.state = state
        self.configured = configured
    }
}

class GenericNotif
{
    var id: String
    var title: String
    var place: String
    var time: Date
    
    init(title: String, place: String, time: Date, id: String)
    {
        self.title = title
        self.place = place
        self.time = time
        self.id = id
    }
}

class WifiList
{
    var ssid: String
    
    init(ssid: String)
    {
        self.ssid = ssid
    }
}

class ResponseMessage
{
    var status: String?
    var message: String?
    
    init(status: String?, message: String?)
    {
        self.status = status
        self.message = message
    }
}

class APIResponse
{
    var response: ResponseMessage?
    var data: Any?
    
    init(response: ResponseMessage?, data: Any?)
    {
        self.response = response
        self.data = data
    }
}
