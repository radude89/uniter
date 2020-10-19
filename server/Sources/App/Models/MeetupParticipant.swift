//
//  MeetupParticipant.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

public final class MeetupParticipant: Model {
    public static let schema = "meetup+participant"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "meetup_id")
    public var meetup: Meetup
    
    @Parent(key: "participant_id")
    public var participant: Participant
    
    public init() { }
    
    public init(id: UUID? = nil, meetup: Meetup, participant: Participant) throws {
        self.id = id
        self.$meetup.id = try meetup.requireID()
        self.$participant.id = try participant.requireID()
    }
}

public struct CreateMeetupParticipant: Migration {
    public init() {}
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MeetupParticipant.schema)
            .id()
            .field("meetup_id", .uuid, .references(Meetup.schema, "id"))
            .field("participant_id", .uuid, .references(Participant.schema, "id"))
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MeetupParticipant.schema).delete()
    }
}
