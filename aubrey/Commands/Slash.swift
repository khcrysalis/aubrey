//
//  Slash.swift
//  aubrey
//
//  Created by samara on 8/29/23.
//

import Foundation
import Discord
import OSLog
import BotConfig

extension Aubrey {
    static func addCommandsToBot() {
        bot.addSlashCommand(
            name: "Me",
            description: "Shows stuff about you :)",
            guildId: nil,
            onInteraction: { interaction async in
                do {
                    if let member = interaction.user as? Member {
                        
                        let joinedf = snowflakeToTimestamp(member.joinedAt.asSnowflake, format: "f")
                        let joinedR = snowflakeToTimestamp(member.joinedAt.asSnowflake, format: "R")
                        
                        let createdf = snowflakeToTimestamp(Snowflake(member.id.description) ?? 0, format: "f")
                        let createdR = snowflakeToTimestamp(Snowflake(member.id.description) ?? 0, format: "R")
                        
                        let sortedRoles = member.roles.sorted { $0.position > $1.position }
                        let rolesList = sortedRoles.map { "<@&\($0.id.description)>" }.joined(separator: " ")
                        
                        let meEmbed = Embed( color: .random )
                            .setAuthor(name: (member.nick ?? member.user?.description ?? "OK"), url: "https://discordapp.com/users/" + member.id.description, iconUrl: member.user?.avatar?.url)
                            .addField(name: "Username", value: member.user!.name, inline: true)
                            .addField(name: "Identifier", value: member.id.description)
                            .addField(name: "Joined at", value: joinedf + " (\(joinedR))", inline: true)
                            .addField(name: "Created at", value: createdf + " (\(createdR))", inline: true)
                            .addField(name: "Roles", value: rolesList)
                            .setImage(url: member.user?.banner?.url ?? "")
                        
                        try await interaction.respondWithMessage(
                            embeds: [meEmbed],
                            ephemeral: true,
                            ui: meEmbedButtons
                        )
                    }
                } catch {
                    logger.error("Error sending embed: \(error)")
                }
            }
        )
        
        bot.addSlashCommand(
            name: "compliment",
            description: "compliments a qt",
            guildId: nil,
            onInteraction: { interaction async in
                let data = interaction.data as! ApplicationCommandData
                let channel = interaction.channel as? TextChannel
                var msg: String? 
                do {
                    msg = "\(interaction.user.id)"
                    if let messageOption = data.options?.first(where: { $0.name == "mention" }) {
                        if let messageValue = messageOption.value as? String {
                            msg = messageValue
                        }
                    }
                    
                    if let url = URL(string: "https://www.generatormix.com/random-compliment-generator?number=1") {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        
                        if let htmlString = String(data: data, encoding: .utf8) {
                            let pattern = "<blockquote class=\"text-left\">(.*?)</blockquote>"
                            
                            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                                if let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) {
                                    let range = Range(match.range(at: 1), in: htmlString)
                                    if let range = range {
                                        var compliment = String(htmlString[range])
                                        
                                        compliment = compliment.replacingOccurrences(of: #"[^a-zA-Z\s]"#, with: "", options: .regularExpression)
                                        
                                        let doneEmbed = Embed(title: "Done :)", description: "Hope I made your day better <3", color: .pink)
                                        try await interaction.respondWithMessage(embeds: [doneEmbed], ephemeral: true)
                                        try await channel?.send(compliment+" <@\(msg ?? "meow")>")
                                    }
                                }
                            }
                        }
                    }


                } catch {
                    logger.error("Error sending compliment: \(error)")
                }
            },
            options: [
                .init(.mentionable, name: "mention", description: "mention an oomfie", required: false),
            ]
        )


        
        bot.addSlashCommand(
            name: "Say",
            description: "Send a message",
            guildId: nil,
            onInteraction: { interaction async in
                let data = interaction.data as! ApplicationCommandData
                let channel = interaction.channel as? TextChannel
                var message: String?

                if let messageOption = data.options?.first(where: { $0.name == "message" }) {
                    if let messageValue = messageOption.value as? String {
                        message = messageValue
                        if let member = interaction.user as? Member {
                            print("\(member.nick ?? "WHO") ```(\(member.user?.name ?? "WHO"))```: sent \"\(String(describing: messageValue))\"")
                        }
                    }
                }

                if let attachment = data.results.attachments.first {
                    if attachment.size <= 8_000_000 {
                        if let file = try? await attachment.download() {
                            do {
                                let doneEmbed = Embed(title: "Done!", description: "Message sent successfully", color: .green)
                                try await channel?.send(message, files: [file])
                                try await interaction.respondWithMessage(embeds: [doneEmbed], ephemeral: true)
                            } catch {
                                logger.error("Error sending message: \(error)")
                            }
                            return
                        } else {
                            logger.error("Failed to download attachment")
                        }
                    } else {
                        let errorEmbed = Embed(title: "Error", description: "Attachment size exceeds the 8 MB limit.", color: .red)
                        try! await interaction.respondWithMessage(embeds: [errorEmbed], ephemeral: true)
                    }
                }


                do {
                    let doneEmbed = Embed(title: "Done!", description: "Message sent successfully", color: .green)
                    try await channel?.send(message)
                    try await interaction.respondWithMessage(embeds: [doneEmbed], ephemeral: true)
                } catch {
                    logger.error("Error sending message: \(error)")
                }
            },
            options: [
                .init(.string, name: "message", description: "The text to send", required: true),
                .init(.attachment, name: "attachment", description: "Send an attachment (max 8 MB)", required: false)
            ],
            defaultMemberPermissions: Permissions(enable: [.administrator])
        )
    }
}
