//
//  Mlarray.swift
//  ScanFit
//
//  Created by Lana Alyahya on 09/03/2025.
//

import CoreML

extension MLMultiArray {
    func toArray() -> [Float] {
        var array: [Float] = []
        for i in 0..<self.count {
            array.append(self[i].floatValue)
        }
        return array
    }
}
