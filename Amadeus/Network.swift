//
//  Network.swift
//  Amadeus
//
//  Created by Theo Caselli on 15/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AFDateHelper

class Network
{
    class connection
    {
        class func searchBox(completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            API.call(APIEndPoint: "searchbox", completionHandler:
                { response, error in
                
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
                })
        }
        
        class func sendToken(token: String, completionHandler: @escaping (ResponseMessage?, String?) -> Void)
        {
            let body = ("token=" + token).data(using: .utf8)
            
            API.call(APIEndPoint: "sendtoken", method: .post, body: body, completionHandler:
                { response, error in
                    
                    if (error == nil)
                    {
                        let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                        
                        let token = (APIRep.data as? JSON)?.string

                        completionHandler(APIRep.response, token)
                    }
                    else
                    {
                        var alamoError: ResponseMessage?
                        
                        if (error?._code == NSURLErrorTimedOut)
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                        }
                        else
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                        }
                        
                        completionHandler(alamoError, nil)
                    }
            })
        }
        
        class func sendUserData(FCMToken: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            var body = ("fcmtoken=" + FCMToken).data(using: .utf8)
            
            body?.append(("&devicetoken=" + UIDevice.current.identifierForVendor!.uuidString).data(using: .utf8)!)
            
            body?.append(("&name=" + UIDevice.current.name).data(using: .utf8)!)
            
            API.call(APIEndPoint: "user/data", method: .post, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func checkInternet(completionHandler: @escaping (ResponseMessage?, [WifiList]?) -> Void)
        {
            API.call(APIEndPoint: "checkinternet", completionHandler:
                { response, error in
                    
                    if (error == nil)
                    {
                        let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                        var ssidList: [WifiList] = []
                        
                        if let array = (APIRep.data as? JSON)?.array
                        {
                            for item in array
                            {
                                let genWifi = WifiList(ssid: item["ssid"].string ?? "Error")
                                
                                ssidList.append(genWifi)
                            }
                        }
                        
                        completionHandler(APIRep.response, ssidList)
                    }
                    else
                    {
                        var alamoError: ResponseMessage?
                        
                        if (error?._code == NSURLErrorTimedOut)
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                        }
                        else
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                        }
                        
                        completionHandler(alamoError, nil)
                    }
            })
        }
        
        class func setWifi(ssid: String, password: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            var body = ("ssid=" + ssid).data(using: .utf8)
            
            body?.append(("&pass=" + password).data(using: .utf8)!)
            
            API.call(APIEndPoint: "setwifi", method: .post, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func deleteUser(completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("devicetoken=" + UIDevice.current.identifierForVendor!.uuidString).data(using: .utf8)
            
            API.call(APIEndPoint: "user/delete", method: .post, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
    }
    
    class notifications
    {
        class func resetBadge(completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("devicetoken=" + UIDevice.current.identifierForVendor!.uuidString).data(using: .utf8)

            API.call(APIEndPoint: "resetbadge", method: .post, body: body, completionHandler:
            { response, error in
                    
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func list(completionHandler: @escaping (ResponseMessage?, [GenericNotif]?) -> Void)
        {
            API.call(APIEndPoint: "notifications", completionHandler:
                { (response, error) in
                    
                    if (error == nil)
                    {
                        let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                        var notifListArray: [GenericNotif] = []
                        
                        if let array = (APIRep.data as? JSON)?.array
                        {
                            for item in array
                            {
                                let genNotif = GenericNotif(title: item["name"].string ?? "Name Error", place: item["place"].string ?? "Place Error", time: Date(fromString: item["date"].string ?? "1970-01-01T00:00:01.123Z", format: .custom("YYYY-MM-dd'T'HH:mm:ss.SSSX"))!, id: item["_id"].string ?? "ID Error")
                                
                                notifListArray.append(genNotif)
                            }
                        }
                        
                        completionHandler(APIRep.response, notifListArray)
                    }
                    else
                    {
                        var alamoError: ResponseMessage?
                        
                        if (error?._code == NSURLErrorTimedOut)
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                        }
                        else
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                        }
                        
                        completionHandler(alamoError, nil)
                    }
            })
        }
    }
    
    class func genericResponseWithoutData(response: Any?, error: Error?, completionHandler: @escaping (ResponseMessage?) -> Void)
    {
        if (error == nil)
        {
            let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
            
            completionHandler(APIRep.response)
        }
        else
        {
            var alamoError: ResponseMessage?
            
            if (error?._code == NSURLErrorTimedOut)
            {
                alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
            }
            else
            {
                alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
            }
            
            completionHandler(alamoError)
        }
    }

    class func genericReceiver(vc: UIViewController, title: String = "Error", response: ResponseMessage, successHandler: (() -> Void)? = nil, failureHandler: (() -> Void)? = nil)
    {
        guard let rep = response.status else
        {
            Utilities.ui.alertView(vc: vc, title: "network.response.error.title".localized, body: "network.response.error.text".localized)
            return
        }
        
        if (rep == "success")
        {
            if let sucHandler = successHandler
            {
                sucHandler()
            }
        }
        else if (rep == "networkfailure")
        {
            if let failHandler = failureHandler
            {
                failHandler()
            }
            
            if let err = response.message
            {
                Utilities.ui.alertView(vc: vc, title: "network.error".localized, body: err)
            }
        }
        else
        {
            if let failHandler = failureHandler
            {
                failHandler()
            }
            
            if let err = response.message
            {
                Utilities.ui.alertView(vc: vc, title: title, body: err)
            }
        }
    }
    
    class micro
    {
        class func light(id: String, light: Bool, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("light=" + String(light)).data(using: .utf8)
            
            API.call(APIEndPoint: "micro/light/" + id, method: .put, body: body, completionHandler:
            { response, error in
                    
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func delete(id: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            API.call(APIEndPoint: "micro/" + id, method: .delete, completionHandler:
            { response, error in
                    
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func add(name: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("name=" + name).data(using: .utf8)
            
            API.call(APIEndPoint: "micro", method: .post, body: body, completionHandler:
            { response, error in
                    
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func modify(id: String, name: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("name=" + name).data(using: .utf8)
            
            API.call(APIEndPoint: "micro/" + id, method: .put, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func list(completionHandler: @escaping (ResponseMessage?, [GenericMic]?) -> Void)
        {
            API.call(APIEndPoint: "micro", completionHandler:
                { (response, error) in
                    
                    if (error == nil)
                    {
                        let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                        var micListArray: [GenericMic] = []
                        
                        if let array = (APIRep.data as? JSON)?.array
                        {
                            for item in array
                            {
                                let genMic = GenericMic(micName: item["name"].string ?? "Name Error", micID: item["_id"].string ?? "ID Error", battery: item["battery"].int ?? -1, state: item["isFunctional"].int ?? -1, configured: item["isConfigured"].bool ?? false)
                                
                                micListArray.append(genMic)
                            }
                        }
                        
                        completionHandler(APIRep.response, micListArray)
                    }
                    else
                    {
                        var alamoError: ResponseMessage?
                        
                        if (error?._code == NSURLErrorTimedOut)
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                        }
                        else
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                        }
                        
                        completionHandler(alamoError, nil)
                    }
            })
        }
    }
    
    class sound
    {
        class func modifyNotification(id: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("devicetoken=" + UIDevice.current.identifierForVendor!.uuidString).data(using: .utf8)
            
            API.call(APIEndPoint: "sound/notification/" + id, method: .put, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func notifications(completionHandler: @escaping (ResponseMessage?, [String]?) -> Void)
        {
            let body = ("devicetoken=" + UIDevice.current.identifierForVendor!.uuidString).data(using: .utf8)
            
            API.call(APIEndPoint: "sound/notification/", method: .put, body: body, completionHandler:
                { (response, error) in
                    
                    if (error == nil)
                    {
                        let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                        var notifListArray: [String] = []
                        
                        if let array = (APIRep.data as? JSON)?.array
                        {
                            for item in array
                            {
                                let soundID = item.string ?? "Error"
                                
                                notifListArray.append(soundID)
                            }
                        }
                        
                        completionHandler(APIRep.response, notifListArray)
                    }
                    else
                    {
                        var alamoError: ResponseMessage?
                        
                        if (error?._code == NSURLErrorTimedOut)
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                        }
                        else
                        {
                            alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                        }
                        
                        completionHandler(alamoError, nil)
                    }
            })
        }

        class func delete(id: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            API.call(APIEndPoint: "sound/" + id, method: .delete, completionHandler:
            { response, error in
                
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func add(name: String, type: String, data: Data?, data2: Data?, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            API.callUploadSound(name: name, type: type, soundData: data ?? nil, soundData2: data2 ?? nil, completionHandler:
            { response, error in
                    
                Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func modify(id: String, name: String, completionHandler: @escaping (ResponseMessage?) -> Void)
        {
            let body = ("name=" + name).data(using: .utf8)
            
            API.call(APIEndPoint: "sound/" + id, method: .put, body: body, completionHandler:
                { response, error in
                    
                    Network.genericResponseWithoutData(response: response, error: error, completionHandler: completionHandler)
            })
        }
        
        class func list(completionHandler: @escaping (ResponseMessage?, [GenericSound]?) -> Void)
        {
            API.call(APIEndPoint: "sound", completionHandler:
            { (response, error) in
                
                if (error == nil)
                {
                    let APIRep = Utilities.myJSON.genericResponseParser(JSONRep: response)
                    var soundListArray: [GenericSound] = []

                    if let array = (APIRep.data as? JSON)?.array
                    {
                        for item in array
                        {
                            let genSound = GenericSound(soundName: item["name"].string ?? "Name Error", soundID: item["_id"].string ?? "ID Error", notification: item["notification"].bool ?? false)
                            
                            soundListArray.append(genSound)
                        }
                    }
                    
                    completionHandler(APIRep.response, soundListArray)
                }
                else
                {
                    var alamoError: ResponseMessage?
                    
                    if (error?._code == NSURLErrorTimedOut)
                    {
                        alamoError = ResponseMessage(status: "networkfailure", message: "network.timeout".localized)
                    }
                    else
                    {
                        alamoError = ResponseMessage(status: "networkfailure", message: error?.localizedDescription)
                    }
                    
                    completionHandler(alamoError, nil)
                }
            })
        }
    }
}

class API
{
    class func call(APIEndPoint: String, method: HTTPMethod = HTTPMethod.get, body: Data? = nil, completionHandler: @escaping (Any?, Error?) -> Void)
    {
        var request = URLRequest(url: URL(string: APIURL + APIEndPoint)!)
        
        request.httpMethod = method.rawValue
        
        if (body != nil)
        {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        manager.request(request).responseJSON
        { response in
            
            switch response.result
            {
            case .success(let result):
                completionHandler(result, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    class func callUploadSound(name: String, type: String, soundData: Data? = nil, soundData2: Data? = nil, completionHandler: @escaping (Any?, Error?) -> Void)
    {
        manager.upload(multipartFormData:
        { multipartFormData in
            if let tmpSoundData = soundData
            {
                multipartFormData.append(tmpSoundData, withName: "sound", fileName: name, mimeType: "audio/x-caf")
            }
            
            if let tmpSoundData2 = soundData2
            {
                multipartFormData.append(tmpSoundData2, withName: "soundtwo", fileName: name + "_2", mimeType: "audio/x-caf")
            }
            
            multipartFormData.append(type.data(using: .utf8)!, withName: "type", fileName: type, mimeType: "text/plain")
        },
             to: APIURL + "sound",
             encodingCompletion:
             { encodingResult in

                switch encodingResult
                {
                case .success(let upload, _, _):
                    upload.responseJSON
                    { response in
                        switch response.result
                        {
                        case .success(let result):
                            completionHandler(result, nil)
                        case .failure(let error):
                            completionHandler(nil, error)
                        }
                    }
                case .failure(let error):
                    completionHandler(nil, error)
                }
        })
    }
}
