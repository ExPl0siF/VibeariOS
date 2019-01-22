//
//  Utilities.swift
//  Amadeus
//
//  Created by Theo Caselli on 15/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation

class Utilities
{
    class misc
    {
        class func resetBadge()
        {
            UIApplication.shared.applicationIconBadgeNumber = 0
            Network.notifications.resetBadge{ _ in }
        }
    }

    class userDefault
    {
        class func getValue(key: String) -> String?
        {
            return (UserDefaults.standard.string(forKey: key))
        }
        
        class func getValue(key: String) -> Bool?
        {
            return (UserDefaults.standard.bool(forKey: key))
        }
        
        class func setValue(key: String, value: String)
        {
            UserDefaults.standard.set(value, forKey: key)
        }
        
        class func setValue(key: String, value: Bool)
        {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    class ui
    {
        class func alertView(vc: UIViewController, title: String, body: String, completionHandler: ((UIAlertAction) -> Void)? = nil)
        {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: completionHandler))
            
            vc.present(alert, animated: true, completion: nil)
        }
        
        class func alertViewYesNo(vc: UIViewController, title: String, body: String, yesHandler: ((UIAlertAction) -> Void)? = nil, noHandler: ((UIAlertAction) -> Void)? = nil)
        {
            let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "yes".localized, style: UIAlertAction.Style.destructive, handler: yesHandler))
            alert.addAction(UIAlertAction(title: "no".localized, style: UIAlertAction.Style.default, handler: noHandler))
            
            vc.present(alert, animated: true, completion: nil)
        }
        
        class func alertViewNoResponse(vc: UIViewController)
        {
            let alert = UIAlertController(title: "error".localized, message: "network.noresp".localized, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    class myJSON
    {
        class func genericResponseParser(JSONRep: Any?) -> APIResponse
        {
            guard let rep = JSONRep else
            {
                return APIResponse.init(response: nil, data: nil)
            }
            
            let json = JSON(rep)
            
            let response = ResponseMessage(status: json["status"].string, message: json["message"].string)
            
            let data = json["data"]
            
            return APIResponse.init(response: response, data: data)
        }
    }
    
    class sound: NSObject, AVAudioPlayerDelegate
    {
        class func initRecorder(vc: UIViewController, sound: Int) -> AVAudioRecorder?
        {
            var audioRecorder: AVAudioRecorder?
            
            let audioSession = AVAudioSession.sharedInstance()
            
            var recordSettings =
                [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                 AVEncoderBitRateKey: 16,
                 AVNumberOfChannelsKey: 1,
                 AVSampleRateKey: 44100.0] as [String: Any]
            
            if #available(iOS 11.0, *)
            {
                recordSettings =
                    [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                     AVEncoderBitRateKey: 16,
                     AVNumberOfChannelsKey: 1,
                     AVSampleRateKey: 44100.0,
                     AVAudioFileTypeKey: kAudioFileWAVEType] as [String: Any]
            }
            
            switch audioSession.recordPermission
            {
            case AVAudioSession.RecordPermission.denied:
                    Utilities.ui.alertView(vc: vc, title: "permissiondenied.title".localized, body: "permissiondenied.text".localized, completionHandler:
                    { _ in
                        
                        if #available(iOS 10.0, *)
                        {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        
                        vc.dismiss(animated: true, completion: nil)
                    })
                default:
                    break
            }
            
            do
            {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            }
            catch let error as NSError
            {
                print("audioSession error: \(error.localizedDescription)")
            }

            do
            {
                if (sound == 1)
                {
                    try audioRecorder = AVAudioRecorder(url: SOUNDURL, settings: recordSettings as [String: AnyObject])
                }
                else if (sound == 2)
                {
                    try audioRecorder = AVAudioRecorder(url: SOUNDURL2, settings: recordSettings as [String: AnyObject])
                }
               
                audioRecorder?.prepareToRecord()
            }
            catch let error as NSError
            {
                print("audioSession error: \(error.localizedDescription)")
            }
            
            return audioRecorder
        }
        
        class func initPlayer(sound: Int) -> AVAudioPlayer?
        {
            var audioPlayer: AVAudioPlayer?
            
            do
            {
                if (sound == 1)
                {
                    try audioPlayer = AVAudioPlayer(contentsOf: SOUNDURL)
                }
                else if (sound == 2)
                {
                    try audioPlayer = AVAudioPlayer(contentsOf: SOUNDURL2)
                }
                
                audioPlayer!.prepareToPlay()
            }
            catch let error as NSError
            {
                print("audioPlayer error: \(error.localizedDescription)")
            }
            
            return audioPlayer
        }
        
        class func record(audioRecorder: AVAudioRecorder?)
        {
            audioRecorder?.record()
        }
        
        class func stopRecord(audioRecorder: AVAudioRecorder?)
        {
            audioRecorder?.stop()
        }
        
        class func play(audioPlayer: AVAudioPlayer?)
        {
            audioPlayer?.play()
        }
        
        class func stop(audioPlayer: AVAudioPlayer?)
        {
            audioPlayer?.stop()
        }
    }
}
