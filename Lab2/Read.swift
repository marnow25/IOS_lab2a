//
//  Reading.swift
//  Lab2
//
//  Created by Marcin on 1/30/20.
//  Copyright © 2020 Marcin. All rights reserved.
//

import Foundation

class Read: NSObject, NSCoding {
    var sensor: Sensor //czujnik
    var result: Float //rezultat
    var date: Date //data
    
    init(sensor: Sensor, result: Float, date: Date) {
        self.sensor = sensor
        self.result = result
        self.date = date
    }
    
    func showRead() -> String { //odczytanie w widoku
        var toShow: String = ""
        toShow = self.sensor.showSensor()
        
        let formatDate = DateFormatter()
        formatDate.timeStyle = .full
        formatDate.dateStyle = .full
        print("Wynik: \(self.result) | " + formatDate.string(from: self.date))
        return toShow + ", wynik: \(self.result) | " + formatDate.string(from: self.date) + "\n"
    }
    
    func encode(with aCoder: NSCoder) { //kodowanie do pliku
        aCoder.encode(self.sensor, forKey: "sensor")
        aCoder.encode(self.result, forKey: "result")
        aCoder.encode(self.date, forKey: "date")
    }
    
    required convenience init?(coder aDecoder: NSCoder) { //dekodowanie z pliku
        guard
            let sensor = aDecoder.decodeObject(forKey: "sensor") as? Sensor,
            let result = aDecoder.decodeFloat(forKey: "result") as Float?,
            let date = aDecoder.decodeObject(forKey: "date") as? Date
            else {
                return nil
        }
        
        self.init(
            sensor: sensor,
            result: result,
            date: date
        )
    }
}
