//
//  Buttons.swift
//  aubrey
//
//  Created by samara on 11/7/23.
//

import Foundation
import Discord
import OSLog
import BotConfig

let meEmbedButtons = UI()
    .addItem(Button(style: .primary, label: "Copy ID", customId: "id"))
    .addItem(Button(style: .primary, label: "Get Avatar", customId: "ga"))
    .onInteraction({ interaction async in
        let data = interaction.data as! MessageComponentData
        if let member = interaction.user as? Member {
            if data.customId == "id" {
                try! await interaction.respondWithMessage(member.id.description, ephemeral: true)
            }
            if data.customId == "ga" {
                if let avatarURL = member.user?.avatar?.url {
                    let avatarEmbed = Embed(color: .random)
                        .setTitle(member.user!.name+"'s avatar")
                        .setImage(url: avatarURL+"?size=4096")
                    try! await interaction.respondWithMessage(
                        embeds: [avatarEmbed],
                        ephemeral: true,
                        ui: avatarEmbedButtons
                    )
                }
            }

        }
        
    })

let avatarEmbedButtons = UI()
    .addItem(Button(style: .primary, label: "Send to Archive", customId: "sta"))
    .onInteraction({ interaction async in
        let data = interaction.data as! MessageComponentData
        if let member = interaction.user as? Member {
//            if data.customId == "sta" {
//                if message.author.id == owner {
//                    
//                    try! await interaction.respondWithMessage("Sent!", ephemeral: true)
//                    
//                }
//            }

        }
        
    })
