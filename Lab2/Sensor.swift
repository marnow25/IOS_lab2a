//
//  Sensor.swift
//  Lab2
//
//  Created by Marcin on 1/30/20.
//  Copyright © 2020 Marcin. All rights reserved.
//

import Foundation

class Sensor: NSObject, NSCoding {

    var name: String
    var design: String
    
    init(name: String, design: String){ //inicjalizacja czujnika
        self.name = name
        self.design = design
    }
    
    func showSensor() -> String{ //wyswietlenie sensora
        print("Sensor \(name): \(design)")
        return "Sensor \(name): \(design) \n"
    }
    
    func encode(with aCoder: NSCoder) { //kodowanie do pliku
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.design, forKey: "design")
    }
    
    required convenience init?(coder aDecoder: NSCoder) { //dekodowanie z pliku
        
        guard
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let design = aDecoder.decodeObject(forKey: "design") as? String
        else {
            return nil
        }
        
        self.init(
            name: name,
            design: design
        )
    }
}
