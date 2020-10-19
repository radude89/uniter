//
//  Meetup.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

public final class Meetup: Model {
    public static let schema = "meetups"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Siblings(through: MeetupParticipant.self, from: \.$meetup, to: \.$participant)
    public var participants: [Participant]
    
    public init() {}
    
    public init(id: UUID? = nil, name: String, description: String, createdAt: Date? = nil) {
        self.id = id
        self.description = description
        self.createdAt = createdAt
    }
    
}

public struct CreateMeetup: Migration {
    public init() {}
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Meetup.schema)
            .id()
            .field("name", .string)
            .field("description", .string)
            .field("created_at", .date)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Meetup.schema).delete()
    }
}

extension Meetup: Content {}
