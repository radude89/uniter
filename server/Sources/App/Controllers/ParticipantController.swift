//
//  ParticipantController.swift
//  
//
//  Created by Radu Dan on 11/08/2020.
//

import Vapor
import Fluent

struct ParticipantController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let meetupRoute = routes.grouped("api", "participants")
        meetupRoute.post(use: create)
        meetupRoute.get(use: getAll)
        meetupRoute.get(":id", use: get)
        meetupRoute.put(":id", use: update)
        meetupRoute.delete(":id", use: delete)
        meetupRoute.get(":id", "meetups", use: getMeetups)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Participant> {
        let participant = try req.content.decode(Participant.self)
        return participant.save(on: req.db).map { participant }
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Participant]> {
        return Participant.query(on: req.db).all()
    }
    
    func get(_ req: Request) throws -> EventLoopFuture<Participant> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Participant.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func update(req: Request) throws -> EventLoopFuture<Participant> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let updatedParticipant = try req.content.decode(Participant.self)
        
        return Participant.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { participant in
                participant.firstName = updatedParticipant.firstName
                participant.lastName = updatedParticipant.lastName
                
                return participant.save(on: req.db).map { participant }
            }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Participant.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    func getMeetups(req: Request) throws -> EventLoopFuture<[Meetup]> {
        let participant = Participant.find(req.parameters.get("id", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return participant.flatMap { $0.$meetups.query(on: req.db).all() }
    }
}
