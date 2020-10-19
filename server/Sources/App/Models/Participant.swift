//
//  Participant.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent
import FluentSQLiteDriver

public final class Participant: Model {
    public static let schema = "participants"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "first_name")
    public var firstName: String
    
    @Field(key: "last_name")
    public var lastName: String
    
    @Siblings(through: MeetupParticipant.self, from: \.$participant, to: \.$meetup)
    public var meetups: [Meetup]
    
    public init() {}
    
    public init(id: UUID? = nil, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
    
}

public struct CreateParticipant: Migration {
    public init() {}
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema)
            .id()
            .field("first_name", .string)
            .field("last_name", .string)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema).delete()
    }
}

extension Participant: Content {}
