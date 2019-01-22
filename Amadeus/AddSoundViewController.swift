//
//  AddSoundViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 10/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AddSoundViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordButton2: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButton2: UIButton!
    @IBOutlet weak var soundNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var soundNameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var viewContainerAudio: UIView!
    @IBOutlet weak var viewContainerAudio2: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer2: AVAudioPlayer?
    var audioRecorder2: AVAudioRecorder?
    var myTimer: Timer?
    var myTimer2: Timer?
    var onRecord: Bool? = false
    var onRecord2: Bool? = false
    var onPlay: Bool? = false
    var onPlay2: Bool? = false
    var pickerData: [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.soundNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        self.localize()
        
        self.audioRecorder = Utilities.sound.initRecorder(vc: self, sound: 1)
        self.audioRecorder2 = Utilities.sound.initRecorder(vc: self, sound: 2)
        
        self.pickerData = ["Ringtone", "Bell", "Kitchen Objects", "Others"]
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.view.backgroundColor = UIColor.vibearBackground
        self.viewContainerAudio.backgroundColor = UIColor.vibearBackground
        self.viewContainerAudio2.backgroundColor = UIColor.vibearBackground
        
        if (NIGHTMODE == true)
        {
            self.saveButton.tintColor = UIColor.white
            self.cancelButton.tintColor = UIColor.white
        }
        else
        {
            self.saveButton.tintColor = UIColor.black
            self.cancelButton.tintColor = UIColor.black
        }
    }
    
    private func localize()
    {
        self.title = "addsound.title".localized
        self.soundNameLabel.localized("addsound.soundnamelabel")
        self.cancelButton.localized("addsound.cancel")
        self.saveButton.localized("addsound.save")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if (player == self.audioPlayer)
        {
            playButton.tintColor = UIColor.vibearBlue
            self.recordButton.isEnabled = true
            self.onPlay = false
        }
        else if (player == self.audioPlayer2)
        {
            playButton2.tintColor = UIColor.vibearBlue
            self.recordButton2.isEnabled = true
            self.onPlay2 = false
        }
    }
    
    private func goBack()
    {
        self.deleteSound()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelAddSound(_ sender: Any)
    {
        self.goBack()
    }
    
    private func deleteSound()
    {
        do
        {
            try FileManager.default.removeItem(atPath: SOUNDURL.relativePath)
            try FileManager.default.removeItem(atPath: SOUNDURL2.relativePath)
        }
        catch let error
        {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    @IBAction private func saveSound(_ sender: Any)
    {
        if (soundNameTextField.text == "")
        {
            Utilities.ui.alertView(vc: self, title: "error".localized, body: "addsound.noname".localized)
            return
        }
        
        saveButton.isEnabled = false
        self.dismissKeyboard()
        
        let soundData = try? Data(contentsOf: SOUNDURL)
        let soundData2 = try? Data(contentsOf: SOUNDURL2)
        
        Network.sound.add(name: soundNameTextField.text!, type: self.pickerData[self.pickerView.selectedRow(inComponent: 0)], data: soundData, data2: soundData2)
        { response in
            
            guard let rep = response else
            {
                Utilities.ui.alertViewNoResponse(vc: self)
                return
            }
            
            Network.genericReceiver(vc: self, title: "addsound.cannotsave".localized, response: rep, successHandler:
            {
                self.goBack()
            }, failureHandler:
            {
                self.saveButton.isEnabled = true
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        let titleData = self.pickerData[row]
        
        let myTitle: NSAttributedString
        
        if (NIGHTMODE == true)
        {
            myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        else
        {
            myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
        
        return myTitle
    }

    @objc private func changeRecordColor(_ timer: Timer)
    {
        if (timer == myTimer)
        {
            if (recordButton.tintColor == UIColor.red)
            {
                recordButton.tintColor = UIColor.vibearBlue
            }
            else
            {
                recordButton.tintColor = UIColor.red
            }
        }
        else if (timer == myTimer2)
        {
            if (recordButton2.tintColor == UIColor.red)
            {
                recordButton2.tintColor = UIColor.vibearBlue
            }
            else
            {
                recordButton2.tintColor = UIColor.red
            }
        }

    }
    
    @IBAction private func recordSound(_ sender: Any)
    {
        if (self.onRecord == true)
        {
            recordButton.tintColor = UIColor.vibearBlue
            self.onRecord = false
            self.myTimer?.invalidate()
            playButton.isEnabled = true
            Utilities.sound.stopRecord(audioRecorder: self.audioRecorder)
        }
        else
        {
            recordButton.tintColor = UIColor.red
            self.onRecord = true
            playButton.isEnabled = false
            self.myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.changeRecordColor(_:)), userInfo: nil, repeats: true)
            Utilities.sound.record(audioRecorder: self.audioRecorder)
        }
    }
    
    @IBAction func recordSound2(_ sender: Any)
    {
        if (self.onRecord2 == true)
        {
            recordButton2.tintColor = UIColor.vibearBlue
            self.onRecord2 = false
            self.myTimer2?.invalidate()
            playButton2.isEnabled = true
            Utilities.sound.stopRecord(audioRecorder: self.audioRecorder2)
        }
        else
        {
            recordButton2.tintColor = UIColor.red
            self.onRecord2 = true
            playButton2.isEnabled = false
            self.myTimer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.changeRecordColor(_:)), userInfo: nil, repeats: true)
            Utilities.sound.record(audioRecorder: self.audioRecorder2)
        }
    }
    
    @IBAction private func playSound(_ sender: Any)
    {
        if (self.onPlay == true)
        {
            recordButton.isEnabled = true
            self.onPlay = false
            playButton.tintColor = UIColor.vibearBlue
            Utilities.sound.stop(audioPlayer: self.audioPlayer)
        }
        else
        {
            playButton.tintColor = UIColor.blue
            self.onPlay = true
            recordButton.isEnabled = false
            self.audioPlayer = Utilities.sound.initPlayer(sound: 1)
            self.audioPlayer?.delegate = self
            Utilities.sound.play(audioPlayer: self.audioPlayer)
        }
    }
    
    @IBAction func playSound2(_ sender: Any)
    {
        if (self.onPlay2 == true)
        {
            recordButton2.isEnabled = true
            self.onPlay2 = false
            playButton2.tintColor = UIColor.vibearBlue
            Utilities.sound.stop(audioPlayer: self.audioPlayer2)
        }
        else
        {
            playButton2.tintColor = UIColor.blue
            self.onPlay2 = true
            recordButton2.isEnabled = false
            self.audioPlayer2 = Utilities.sound.initPlayer(sound: 2)
            self.audioPlayer2?.delegate = self
            Utilities.sound.play(audioPlayer: self.audioPlayer2)
        }
    }
}
