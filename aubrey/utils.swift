//
//  utils.swift
//  aubrey
//
//  Created by samara on 11/7/23.
//

import Foundation
import Discord

func snowflakeToTimestamp(_ snowflake: Snowflake, format: Character) -> String {
    let timestamp = Int64(snowflake) >> 22 + 1420070400000
    let timestampShit = timestamp / 1000
    
    /*
     <t:\(timestampSeconds):F>    Tuesday, November 07, 2023 at 9:20 PM
     <t:\(timestampSeconds):f>    November 07, 2023 at 9:20 PM
     <t:\(timestampSeconds):D>    November 07, 2023
     <t:\(timestampSeconds):d>    11/07/2023
     <t:\(timestampSeconds):t>    9:20 PM
     <t:\(timestampSeconds):T>    9:20:02 PM
     <t:\(timestampSeconds):R>    0 seconds ago
     */
    return "<t:\(timestampShit):\(format)>"
}

