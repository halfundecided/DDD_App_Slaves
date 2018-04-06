//
//  ViewController.swift
//  IntercomApp
//
//  Created by Mijeong Ban on 4/2/18.
//  Copyright © 2018 appslaves. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var voiceRecording: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var micRecorder: AVAudioRecorder!

    @IBOutlet weak var recordImage: UIImageView!
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths[0])
        return paths[0]
    }
    
    func startRecording()
    {
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
    
    func stopRecording(success: Bool)
    {
        micRecorder.stop()
        micRecorder = nil
        
        if success {
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


