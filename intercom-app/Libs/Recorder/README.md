# Recorder

[![CI Status](http://img.shields.io/travis/Johannes Gorset/Recorder.svg?style=flat)](https://travis-ci.org/Johannes Gorset/Recorder)
[![Version](https://img.shields.io/cocoapods/v/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)
[![Platform](https://img.shields.io/cocoapods/p/Recorder.svg?style=flat)](http://cocoapods.org/pods/Recorder)

## Usage

```swift
import UIKit
import Recorder

class ViewController: UIViewController, RecorderDelegate {
  var recording: Recording!

  override func viewDidLoad() {
    super.viewDidLoad()

    recording = Recording(to: "recording.m4a")
    recording.delegate = self

    // Optionally, you can prepare the recording in the background to
    // make it start recording faster when you hit `record()`.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      do {
        try self.recording.prepare()
      } catch {
        print(error)
      }
    }
  }

  func start() {
    do {
      try recording.record()
    } catch {
      print(error)
    }
  }

  func stop() {
    recording.stop()
  }

  func play() {
    do {
      try recording.play()
    } catch {
      print(error)
    }
  }
}
```

`RecorderDelegate` just extends `AVAudioRecorderDelegate`, so if you need to
delegate things you can just implement those methods as you would normally do.

## Metering

You can meter incoming audio levels by implementing `audioMeterDidUpdate`:

```swift
func audioMeterDidUpdate(db: Float) {
  print("db level: %f", db)
}
```

## Configuration

The following configurations may be made to the `Recording` instance:

* `bitRate` (default `192000`)
* `sampleRate` (default `41000.0`)
* `channels` (default `1`)

## Requirements

* Balls of steel (it's my first pod, and it's really bad)

## Installation

**Recorder** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Recorder'
```

**Recorder** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "jgorset/Recorder"
```

## Author

Johannes Gorset, jgorset@gmail.com

## License

**Recorder** is available under the MIT license. See the LICENSE file for more info.
