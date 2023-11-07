//
//  logging.swift
//  aubrey
//
//  Created by samara on 8/29/23.
//

import Foundation
import OSLog
import BotConfig
import Discord

let logger = Logger(subsystem: "Aubrey", category: "main")
let token = String(cString: strdup(AB_TOKEN_VALUE))
let owner = Snowflake(AB_OWNER_VALUE)
let bot = Discord(token: token, intents: Intents.default)
