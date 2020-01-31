//
//  ViewController.swift
//  Lab2
//
//  Created by Marcin on 1/30/20.
//  Copyright © 2020 Marcin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var directoryPath: URL!
    var readPath: URL!
    var sensorPath: URL!
    var sensors: [Sensor] = []
    var sensorAmount: Int = 20
    var pastSensors: [Sensor] = []
    var maxReadValue: Float = 100.0
    var readCount: Int = 30000
    var pastRead: [Read] = []
    var reads: [Read] = []
    
    @IBOutlet weak var textToDisplay: UITextView!
    @IBOutlet weak var timeLabelToDisplay:
    UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStorage()
    }

    @IBAction func generateData(_ sender: Any) {
        let start = NSDate()
        self.generateReadsAndSensors()
        saveSensors(sensors: self.sensors)
        saveReads(reads: self.reads)
        let end = NSDate()
        let time = end.timeIntervalSince(start as Date)
        timeLabelToDisplay.text = "Generation time: " + String(time) + " [s]"
    }
    
    @IBAction func findTimestamps(_ sender: Any) {
        let start = NSDate()
        self.findTimestamp()
        let end = NSDate()
        let time = end.timeIntervalSince(start as Date)
        timeLabelToDisplay.text = "Maximum and minimal timestamp evaluated in: " + String(time) + " [s]"
    }
    
    @IBAction func calculateAverage(_ sender: Any) {
        let start = NSDate()
        self.findAverage()
        let end = NSDate()
        let time = end.timeIntervalSince(start as Date)
        timeLabelToDisplay.text = "Average value evaluated in: " + String(time) + " [s]"
    }
    
    @IBAction func calculateAll(_ sender: Any) {
        let start = NSDate()
        self.findAverageAndCountForAll()
        let end = NSDate()
        let time = end.timeIntervalSince(start as Date)
        timeLabelToDisplay.text = "Average and quantity for each  sensor evaluated in: " + String(time) + " [s]"    }
    
    func setStorage() { //tworzenie sciezek dla storage
        self.directoryPath =
            FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        self.sensorPath =
            self.directoryPath.appendingPathComponent("sensors")
        self.readPath =
            self.directoryPath.appendingPathComponent("reads")
    }
    
    func generateReadsAndSensors() { //generowanie sensors i reads
        let base: String = "S0"
        for i in 0...self.sensorAmount-1 {
            let desing = "Sensor number " + String(i)
            self.sensors.append(Sensor(name: base + String(i), design: desing))
        }
        
        var generatedData: String = "Generated data: \n"
        for sen in self.sensors {
            generatedData = generatedData + sen.showSensor()
        }
        
        for _ in 0 ... self.readCount-1 {
            //losowa data
            let interval = TimeInterval.random(in: 0 ... 10000)
            let date = Date.init(timeIntervalSinceNow: interval)
            
            //losowy sensor
            let randomSensor = Int.random(in: 0 ... (sensorAmount-1))
            
            //losowa wartosc
            let value = Float.random(in: 0 ... maxReadValue)
            
            self.reads.append(Read(sensor: self.sensors[randomSensor], result: value, date: date))
        }
        for read in 0 ... 10 {
            generatedData = generatedData + reads[read].showRead()
        }
        textToDisplay.text = generatedData
    }
    
    func saveSensors(sensors: [Sensor]) { //zapisanie sensors w pliku
        print("Saving sensors to file!")
        do {
            let saveData = try
            NSKeyedArchiver.archivedData(withRootObject: sensors,
            requiringSecureCoding: false)
            try saveData.write(to: self.sensorPath)
        }catch{
            print("Error! Writing sensors to file failes!")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
    }
    
    func saveReads(reads: [Read]){ //zapisanie reads do pliku
        print("Saving reads to file!")
        do {
            let saveData = try
                NSKeyedArchiver.archivedData(withRootObject: reads,
                                             requiringSecureCoding: false)
            try saveData.write(to: self.readPath)
        }catch{
            print("Error! Writing reads to file failes!")
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
    }
    
    func readSensors() { //wczytanie sensors z pliku
        self.pastSensors = []
        print("Reading sensors from file!")
        do {
            let data = try Data(contentsOf: self.sensorPath)
            let unArchiver = try
                NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Sensor]?
            self.pastSensors =  unArchiver!
        }catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        for sen in self.pastSensors {
            sen.showSensor()
        }
    }
    
    func readReads() { //wczytanie sensors z pliku
        self.pastRead = []
        print("Read array from file!")
        
        do{
            let data = try Data(contentsOf: self.readPath)
            let unArchiver = try
                NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Read]?
            self.pastRead = unArchiver!
        }catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        
        print("Reading reads done!")
        
        for read in 0 ... 10 {
            self.pastRead[read].showRead()
        }
    }
    
    func findTimestamp() { //znalezienie min i max timestamp
        var min: Date
        var max: Date
        min = Date.init(timeIntervalSinceNow: 0)
        max = Date.init(timeIntervalSinceNow: 12000)
        self.readReads()
        for read in self.pastRead {
            if read.date < min {
                min = read.date
            }
            if read.date > max {
                max = read.date
            }
        }
        
        textToDisplay.text = "Minimal timestamp of sensors: \(min) \n" + "Maximal timestamp of reads: \(max)"
    }
    
    func findAverage() { // znalezienie sredniej wartosci
        var average: Float = 0
        self.readReads()
        for read in self.pastRead { //sumowanie
            average = average + read.result
        }
        
        let averageDivided = average / Float(self.pastRead.count) //dzielenie
        
        textToDisplay.text = "Average value of sensors: \(averageDivided)"
    }
    
    func findAverageAndCountForAll() {
        var countDict: [String:Int] = [:]
        var averageDict: [String:Float] = [:]
        self.readSensors()
        self.readReads()
        
        var displayText: String = ""
        for sen in self.pastSensors {
            averageDict[sen.name] = 0.0
            countDict[sen.name] = 0
        }
        for read in self.pastRead {
            averageDict[read.sensor.name] =
            averageDict[read.sensor.name]! + read.result
            countDict[read.sensor.name] =
            countDict[read.sensor.name]! + 1
        }
        for sen in self.pastSensors {
            if countDict[sen.name] != 0 {
                averageDict[sen.name] =
                    averageDict[sen.name]! /
                Float(countDict[sen.name]!)
            }
            
            displayText = displayText + "sensor:  \(sen.name) -> average \(String(describing: averageDict[sen.name]!)) -> quantity \(String(describing: countDict[sen.name]!)) \n"
        }
        textToDisplay.text = displayText
    }

}

