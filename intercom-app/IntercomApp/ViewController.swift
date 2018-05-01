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

class ViewController: UIViewController, AVAudioRecorderDelegate {
    var voiceRecording: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var micRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var rName = "recording.wav"
    @IBOutlet weak var clientTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({[unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordButton.isEnabled = true
                    }
                    else {
                        self.recordButton.isEnabled = false
                    }
                }
            })
        } catch { }
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(rName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            micRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            micRecorder.delegate = self
            micRecorder.record()
        } catch {
            stopRecording(success: false)
        }
    }
    
    func stopRecording(success: Bool) {
        micRecorder.stop()
        micRecorder = nil
        
        if success {
            postFile()
        } else {
            // recording failed :(
            // show error msg
            print("errror recoreing show msg")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(success: false)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func postFile() {
        let rURL = "https://" + clientTextField.text! + ".ngrok.io/audio"
        var r  = URLRequest(url: URL(string: rURL)!)
        r.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        r.httpBody = createBody(parameters: [:],
                                boundary: boundary,
                                data: try! Data(contentsOf: getDocumentsDirectory().appendingPathComponent(rName)),
                                mimeType: "audio/wav",
                                filename: rName)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: r)
        task.resume()
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
        }
        
        body.append(boundaryPrefix.data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--".appending(boundary.appending("--")).data(using: String.Encoding.utf8)!)
        
        return body as Data
    }

    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordTapped(_ sender: Any) {
        startRecording()
    }
    
    @IBAction func recordEnded(_ sender: Any) {
        stopRecording(success: true)
    }
}
