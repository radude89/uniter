//
//  Participant.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class Participant: Model {
    static let schema = "participants"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Siblings(through: MeetupParticipant.self, from: \.$participant, to: \.$meetup)
    var meetups: [Meetup]
}

struct CreateParticipant: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema)
            .id()
            .field("first_name", .string)
            .field("last_name", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema).delete()
    }
}

extension Participant: Content {}
