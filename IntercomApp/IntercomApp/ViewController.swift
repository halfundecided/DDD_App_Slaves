//
//  ViewController.swift
//  IntercomApp
//
//  Created by Mijeong Ban on 4/2/18.
//  Copyright © 2018 appslaves. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth

class ViewController: UIViewController, AVAudioRecorderDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var voiceRecording: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var micRecorder: AVAudioRecorder!
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    
    //Add CBUUID's
    let NAME = "Onyx"
    let SCRATCH_UUID =
        CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let SERVICE_UUID =
        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    
    @IBOutlet weak var recordImage: UIImageView!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available")
        }
    }
    
    private func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral, advertisementData: [String: AnyObject], RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.contains(NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(
        central: CBCentralManager,
        didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    private func peripheral(
        peripheral: CBPeripheral,
        didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    private func peripheral(
        peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == SCRATCH_UUID {
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
            }
        }
    }
    
    private func centralManager(
        central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: NSError?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
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
    
    @IBAction func connectBT(_ sender: Any) {
        
        manager = CBCentralManager(delegate: self, queue: nil)
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


