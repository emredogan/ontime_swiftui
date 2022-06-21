//
//  Flags.swift
//  OnTime
//
//  Created by Emre Dogan on 21/06/2022.
//

import Foundation

struct Flags {
    static func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
