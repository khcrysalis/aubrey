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
                        
                        let sortedRoles = member.roles.sorted { $0.position > $1.position }
                        let rolesList = sortedRoles.map { "<@&\($0.id.description)>" }.joined(separator: " ")
                        
                        let meEmbed = Embed(
                            color: .random
                        )
                            .setAuthor(name: (member.nick ?? member.user?.description ?? "OK"), url: "https://discord.com/users/" + member.id.description, iconUrl: member.user?.avatar?.url)
                            .addField(name: "Joined at", value: member.joinedAt.formatted(), inline: true)
                            .addField(name: "Created at", value: member.user?.created.description ?? "1969", inline: true)
                            .addField(name: "Identifier", value: member.id.description)
                            .addField(name: "Roles", value: rolesList)
                        
                        try await interaction.respondWithMessage(
                            embeds: [meEmbed],
                            ephemeral: true
                        )
                    }
                } catch {
                    logger.error("Error sending embed: \(error)")
                }
            }
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
                    }
                }

                if let attachment = data.results.attachments.first {
                    if let file = try? await attachment.download() {
                        if attachment.size <= 8_000_000 {
                            do {
                                let doneEmbed = Embed(title: "Done!", description: "Message sent successfully", color: .green)
                                try await interaction.respondWithMessage(embeds: [doneEmbed], ephemeral: true)
                                try await channel?.send(message, files: [file])
                            } catch {
                                logger.error("Error sending message: \(error)")
                            }
                            return
                        } else {
                            let errorMessage = "Attachment size exceeds the 8 MB limit."
                            let errorEmbed = Embed(title: "Error", description: errorMessage, color: .red)
                            try! await interaction.respondWithMessage(embeds: [errorEmbed], ephemeral: true)
                            return
                        }
                    }
                }

                do {
                    let doneEmbed = Embed(title: "Done!", description: "Message sent successfully", color: .green)
                    try await interaction.respondWithMessage(embeds: [doneEmbed], ephemeral: true)
                    try await channel?.send(message)
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
