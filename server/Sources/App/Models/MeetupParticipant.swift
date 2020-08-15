//
//  MeetupParticipant.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

final class MeetupParticipant: Model {
    static let schema = "meetup+participant"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "meetup_id")
    var meetup: Meetup
    
    @Parent(key: "participant_id")
    var participant: Participant
    
    init() { }
    
    init(id: UUID? = nil, meetup: Meetup, participant: Participant) throws {
        self.id = id
        self.$meetup.id = try meetup.requireID()
        self.$participant.id = try participant.requireID()
    }
}

struct CreateMeetupParticipant: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MeetupParticipant.schema)
            .id()
            .field("meetup_id", .uuid, .references(Meetup.schema, "id"))
            .field("participant_id", .uuid, .references(Participant.schema, "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MeetupParticipant.schema).delete()
    }
}
