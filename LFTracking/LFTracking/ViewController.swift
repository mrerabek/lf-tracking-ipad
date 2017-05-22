//
//  ViewController.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 21.04.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var imageStack: LFImageStack!
    @IBOutlet weak var answerButtonsStack: AnswerButtonsStack!
    
    static var trackingFile: URL? = nil
    static var answersFile: URL? = nil
    
    private var currentImageIndex: Int = 0
    private var imagesName: [String] = ["Bikes",
                                        "Danger_de_Mort",
                                        "Flowers"]
//                                        "Fountain_&_Vincent_2",
//                                        "Friends_1",
//                                        "Stone_Pillars_Outside", ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButtonsTarget()
        setupOutputFiles()
        imageStack.imageName = imagesName[currentImageIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didAnswer(button: UIButton) {
        let answer = button.titleLabel?.text
        let imgName = imagesName[currentImageIndex].padding(toLength: 30, withPad: " ", startingAt: 0)
        ViewController.writeLine(String(format:"%@%@", imgName, answer!), toFile: ViewController.answersFile)
        
        if (!isLastImage()){
            currentImageIndex += 1
            imageStack.imageName = imagesName[currentImageIndex]
        }
    }
    
    //MARK: Static Methods
    
    static func write(_ string: String, toFile: URL?){
        if let fileURL = toFile {
            do {
                // Write to the file
                try string.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
    }
    
    static func writeLine(_ string: String, toFile: URL?){
        if let fileURL = toFile {
            let fileHandle: FileHandle? = FileHandle(forUpdatingAtPath: fileURL.path)
            
            if fileHandle == nil {
                print("File open failed")
            } else {
                let data = (string+"\n" as NSString).data(using: String.Encoding.utf8.rawValue)
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(data!)
                fileHandle?.closeFile()
            }
        }
    }
    
    //MARK: Private Methods
    
    private func addButtonsTarget() {
        for button in answerButtonsStack.buttons{
            button.addTarget(self, action: #selector(ViewController.didAnswer(button:)), for: .touchUpInside)
        }
    }
    
    private func setupOutputFiles() {
        
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // Create a timestamp prefix for both the tracking and the answers file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-hh'h'mm"
        let timestamp = dateFormatter.string(from: Date()) + "-"
        
        // Setup tracking file
        let trackingFileName = timestamp + "tracking"
        ViewController.trackingFile = DocumentDirURL.appendingPathComponent(trackingFileName).appendingPathExtension("txt")
        ViewController.write("", toFile: ViewController.trackingFile)
        print("trackingFile path: \(ViewController.trackingFile!.path)")
        
        // Setup answers file
        let answersFileName = timestamp + "answers"
        ViewController.answersFile = DocumentDirURL.appendingPathComponent(answersFileName).appendingPathExtension("txt")
        ViewController.write("", toFile: ViewController.answersFile)
    }
    
    private func isLastImage() -> Bool {
        return currentImageIndex >= (imagesName.count - 1)
    }
    
}

