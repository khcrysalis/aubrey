//
//  bot.swift
//  aubrey
//
//  Created by samara on 8/29/23.
//

import Foundation
import Discord

@main
struct Aubrey {
    static func main() async {
        
        logger.info("Aubrey has awoken.")
        
        Aubrey.addCommandsToBot()
        try! bot.addListeners(MyListener(name: "balls3", logger: logger))
        try! await bot.connect()
    }
}
