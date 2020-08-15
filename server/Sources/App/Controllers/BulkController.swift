//
//  BulkController.swift
//  
//
//  Created by Radu Dan on 15/08/2020.
//

import Vapor
import Fluent

struct BulkController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped("api", "bulk")
        route.post("meetups", use: createMeetups)
        route.post("participants", use: createParticipants)
        route.post("mp", use: createMeetupParticipants)
    }
    
    func createMeetups(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let meetups = try req.content.decode([Meetup].self)
        return meetups
            .create(on: req.db)
            .map { .ok }
    }
    
    func createParticipants(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let participants = try req.content.decode([Participant].self)
        return participants
            .create(on: req.db)
            .map { .ok }
    }
    
    func createMeetupParticipants(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let meetupParticipants = try req.content.decode([MeetupParticipantCreate].self)
        
        return meetupParticipants
            .map { addMeetupParticipant($0, req: req) }
            .flatten(on: req.eventLoop)
            .transform(to: .ok)
    }
    
    private func addMeetupParticipant(_ meetupParticipant: MeetupParticipantCreate, req: Request) -> EventLoopFuture<HTTPStatus> {
        let meetup = Meetup.find(meetupParticipant.meetupID, on: req.db)
            .unwrap(or: Abort(.notFound))
        let participant = Participant.find(meetupParticipant.participantID, on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return meetup.and(participant)
            .flatMap { (meetup, participant) in
                meetup.$participants.attach(participant, on: req.db) }
            .transform(to: .ok)
    }
}

struct MeetupParticipantCreate: Content {
    let meetupID: UUID
    let participantID: UUID
}

struct ImportAllCreate: Content {
    let participant: Participant
    let meetups: [Meetup]
}
