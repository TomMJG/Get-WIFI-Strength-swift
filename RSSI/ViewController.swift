//
//  ViewController.swift
//  RSSI
//
//  Created by 马家固 on 15/11/17.
//  Copyright © 2015年 马家固. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var noteCount = 0
    
    var timer = NSTimer()
    @IBOutlet weak var n: NSTextField!
    @IBOutlet weak var RSSI: NSTextField!
    @IBOutlet weak var noise: NSTextField!
    @IBOutlet weak var SSID: NSTextField!
    var count = 0
    @IBAction func start(sender: NSButton) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "writeInfo:", userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
        self.timer.fire()
        
        writeInfo(timer)
    }
    @IBAction func pause(sender: NSButton) {
        self.timer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        RSSI.enabled = false
        noise.enabled = false
        SSID.enabled = false
        // Do any additional setup after loading the view.
    }
    
    //定义一个定时器
    func doTimer() -> NSTimer {
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "writeInfo:", userInfo: nil, repeats:true)
    
        return timer
    }
    
    func writeInfo(timer: NSTimer) {
        let dict = getRSSI()
        if dict != "" {
            RSSI.stringValue = dict["agrCtlRSSI"] as! String
            noise.stringValue = dict["agrCtlNoise"] as! String
            SSID.stringValue = dict["SSID"] as! String
        }
        let ssid = dict["SSID"] as! String
        let rssi = dict["agrCtlRSSI"]
        let noise2 = dict["agrCtlNoise"]
        //Get Current Time
        let date : NSDate = NSDate()
        let sec : NSTimeInterval = date.timeIntervalSinceNow
        let currentDate : NSDate = NSDate(timeIntervalSinceNow: sec)
        
        //Set time format for output
        let df : NSDateFormatter = NSDateFormatter()
        df.dateFormat = "_hh.mm"
        
        //Create a file
        var fileName : String
        var fileName2 : String
        
        fileName = getDocumentsDirectory().stringByAppendingPathComponent("4.3.txt")
        fileName2 = getDocumentsDirectory().stringByAppendingPathComponent("Gaosi-4.3.txt")
        
        let str = " R   N   SSID\n"
        if count == 0 {
            var _ : NSError
            do {
                try str.writeToFile(fileName, atomically: true, encoding: NSUTF8StringEncoding)
                try "".writeToFile(fileName2, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                print("Fetch failed: \(error.localizedDescription)")
            }
            count++
        }
        //Write to file
        let fh = NSFileHandle(forWritingAtPath: fileName)
        let fh2 = NSFileHandle(forWritingAtPath: fileName2)
        
        fh?.seekToEndOfFile()
        fh?.writeData(rssi!.dataUsingEncoding(NSUTF8StringEncoding)!)
        let space = " "
        let c = "\n"
        let d = ","
        fh?.seekToEndOfFile()
        fh?.writeData(space.dataUsingEncoding(NSUTF8StringEncoding)!)
        fh?.seekToEndOfFile()
        fh?.writeData(noise2!.dataUsingEncoding(NSUTF8StringEncoding)!)
        fh?.seekToEndOfFile()
        fh?.writeData(space.dataUsingEncoding(NSUTF8StringEncoding)!)
        fh?.seekToEndOfFile()
        fh?.writeData(ssid.dataUsingEncoding(NSUTF8StringEncoding)!)
        fh?.seekToEndOfFile()
        fh?.writeData(c.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        fh2?.seekToEndOfFile()
        fh2?.writeData(rssi!.dataUsingEncoding(NSUTF8StringEncoding)!)
        fh2?.seekToEndOfFile()
        fh2?.writeData(d.dataUsingEncoding(NSUTF8StringEncoding)!)
        
    }
    
    func getRSSI() -> NSDictionary {
        //run program in this path
        let task = NSTask()
        task.launchPath = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
        task.arguments = ["-I"]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        //convert RSSI infomation to dictionary
        let dict : NSMutableDictionary = NSMutableDictionary()
        var arr = output?.componentsSeparatedByString("\n")
        if arr != nil {
            for var i = 0; i < arr!.count; i++ {
                let new_str : String = arr![i].stringByReplacingOccurrencesOfString(" ", withString: "")
                if new_str != "" {
                    var array = new_str.componentsSeparatedByString(":")
                    let key = array[0]
                    let value = array[1]
                    dict.setValue(value, forKey: key)
                }
            }
        }
        noteCount++
        n.stringValue = String(noteCount)
        return dict
    }
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

