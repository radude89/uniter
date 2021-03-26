import Vapor
import Fluent

protocol ModelCRUDController: RouteCollection {
    associatedtype ServerModel: Model, Content where ServerModel.IDValue: LosslessStringConvertible
    var idKey: String { get }
    var routeLocation: String { get }
    
    func create(request: Request) throws -> EventLoopFuture<ServerModel>
    func getAll(request: Request) throws -> EventLoopFuture<[ServerModel]>
    func get(request: Request) throws -> EventLoopFuture<ServerModel>
    func update(request: Request) throws -> EventLoopFuture<ServerModel>
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus>
}

extension ModelCRUDController {
    
    var idKey: String { "id" }
    
    var routeLocation: String {
        "\(String(describing: ServerModel.self).lowercased())s"
    }
    
    func create(request: Request) throws -> EventLoopFuture<ServerModel> {
        let model = try request.content.decode(ServerModel.self)
        return model.save(on: request.db).map { model }
    }
    
    func getAll(request: Request) throws -> EventLoopFuture<[ServerModel]> {
        ServerModel.query(on: request.db).all()
    }
    
    func get(request: Request) throws -> EventLoopFuture<ServerModel> {
        ServerModel.from(request: request, key: idKey)
    }
    
    func update(request: Request) throws -> EventLoopFuture<ServerModel> {
        let updatedModel = try request.content.decode(ServerModel.self)
        
        return ServerModel
            .from(request: request, key: idKey)
            .flatMap { model -> EventLoopFuture<ServerModel> in
                let newModel = updatedModel
                newModel.id = updatedModel.id
                newModel._$id.exists = model._$id.exists
                return newModel.update(on: request.db).map { newModel }
            }
    }
    
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        return ServerModel
            .from(request: request, key: idKey)
            .flatMap { $0.delete(on: request.db) }
            .map { .ok }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let idPathComponent = PathComponent(stringLiteral: ":\(idKey)")
        let route = routes.grouped("api", PathComponent(stringLiteral: routeLocation))
        route.post(use: create)
        route.get(use: getAll)
        route.get(idPathComponent, use: get)
        route.put(idPathComponent, use: update)
        route.delete(idPathComponent, use: delete)
    }
}

extension Model where IDValue: LosslessStringConvertible {
    public static func idValue(key: String, on request: Request) -> IDValue? {
        request.parameters.get(key)
    }
    
    public static func from(request: Request, key: String) -> EventLoopFuture<Self> {
        let idValue = Self.idValue(key: key, on: request)
        return Self
            .find(idValue, on: request.db)
            .unwrap(or: Abort(.notFound))
    }
}

struct MeetupCRUDController: ModelCRUDController {    
    typealias ServerModel = Meetup
}
