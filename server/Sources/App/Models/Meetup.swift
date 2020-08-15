//
//  Meetup.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class Meetup: Model {
    static let schema = "meetups"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Siblings(through: MeetupParticipant.self, from: \.$meetup, to: \.$participant)
    var participants: [Participant]
}

struct CreateMeetup: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Meetup.schema)
            .id()
            .field("name", .string)
            .field("description", .string)
            .field("created_at", .date)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Meetup.schema).delete()
    }
}

extension Meetup: Content {}
