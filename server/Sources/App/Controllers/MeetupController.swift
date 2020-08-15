//
//  MeetupController.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent

struct MeetupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let meetupRoute = routes.grouped("api", "meetups")
        meetupRoute.post(use: create)
        meetupRoute.get(use: getAll)
        meetupRoute.get(":id", use: get)
        meetupRoute.put(":id", use: update)
        meetupRoute.delete(":id", use: delete)
        meetupRoute.get(":id", "participants", use: getParticipants)
        meetupRoute.post(":meetupID", "participants", ":participantID", use: addParticipant)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Meetup> {
        let meetup = try req.content.decode(Meetup.self)
        return meetup.save(on: req.db).map { meetup }
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Meetup]> {
        return Meetup.query(on: req.db).all()
    }
    
    func get(_ req: Request) throws -> EventLoopFuture<Meetup> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Meetup.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func update(req: Request) throws -> EventLoopFuture<Meetup> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let updatedMeetup = try req.content.decode(Meetup.self)
        
        return Meetup.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { meetup in
                meetup.name = updatedMeetup.name
                meetup.description = updatedMeetup.description
                
                return meetup.save(on: req.db).map { meetup }
            }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Meetup.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    func getParticipants(req: Request) throws -> EventLoopFuture<[Participant]> {
        let meetup = Meetup.find(req.parameters.get("id", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return meetup.flatMap { $0.$participants.query(on: req.db).all() }
    }
    
    func addParticipant(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let meetup = Meetup.find(req.parameters.get("meetupID", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        let participant = Participant.find(req.parameters.get("participantID", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return meetup.and(participant).flatMap { (meetup, participant) in
            meetup.$participants.attach(participant, on: req.db)
        }.transform(to: .ok)
    }
}
