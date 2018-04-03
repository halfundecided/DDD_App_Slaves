//
//  ViewController.swift
//  IntercomApp
//
//  Created by Mijeong Ban on 4/2/18.
//  Copyright © 2018 appslaves. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	
var voiceRecording: AVAudioPlayer!
var recordingSession: AVAudioSession!
var micRecorder: AVAudioRecorder!


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Record your message."
	recordingSession = AVAudioSession.sharedInstance()

	do {
		try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
		try recordingSession.setActive(true)
	}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


