//
//  ViewController.swift
//  IntercomApp
//
//  Created by Mijeong Ban on 4/2/18.
//  Copyright © 2018 appslaves. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVAudioRecorderDelegate/*, CBCentralManagerDelegate, CBPeripheralDelegate*/ {
    
    var voiceRecording: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var micRecorder: AVAudioRecorder!
    
    var audioPlayer = AVAudioPlayer()
    
    var prepped: Bool = false
    
    @IBOutlet weak var recordImage: UIImageView!
 
    
    @IBAction func connect(_ sender: Any) {
        let alertController = UIAlertController (title: "Connect to Bluetooth", message: "Go to Settings?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: "App-Prefs:root=General") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        print(paths[0])
        return paths[0]
    }
    
    func startRecording()
    {
        if prepped
        {
            audioPlayer.stop()
        }
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            micRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            micRecorder.delegate = self
            micRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            stopRecording(success: false)
        }
    }
    
    func prepAudio()
    {
        prepped = true
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        //let path = Bundle.main.path(forResource: "recording", ofType: "m4a")
       // let music = NSURL(fileURLWithPath: path!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error in shared instance")
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename as URL)
        } catch {
            
        }
        audioPlayer.prepareToPlay()
    }
    
    func stopRecording(success: Bool)
    {
        micRecorder.stop()
        micRecorder = nil
        
        if success {
            
            prepAudio()
            
            audioPlayer.play()
            let wrapperView = UIView(frame: CGRect(x: 60, y: 540, width: 260, height: 20))
            self.view.backgroundColor = UIColor.clear
            self.view.addSubview(wrapperView)
            let volumeView = MPVolumeView(frame: wrapperView.bounds)
            wrapperView.addSubview(volumeView)
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordTapped(_ sender: Any)
    {
        if micRecorder == nil
        {
            startRecording()
        }
        else
        {
            stopRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag {
            stopRecording(success: false)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()

        do
        {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({[unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed
                    {
                        self.recordButton.isEnabled = true
                    }
                    else
                    {
                        self.recordButton.isEnabled = false
                    }
                }
            })
        }
        catch
        {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


