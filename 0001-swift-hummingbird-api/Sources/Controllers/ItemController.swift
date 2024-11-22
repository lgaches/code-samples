import Foundation
import Hummingbird

struct ItemController<Context: RequestContext> {

    let repository: ItemRepository

    func addRoutes(to group: RouterGroup<Context>) {
        group
            .get(use: self.list)
            .get(":id", use: self.get)
            .post(use: self.create)
            .patch(":id", use: self.update)
            .delete(":id", use: self.delete)
    }

    @Sendable
    func list(_ request: Request, context: Context) async throws -> [Item] {
        return await self.repository.list()
    }

    @Sendable
    func get(_ request: Request, context: Context) async throws -> Item? {
        let id = try context.parameters.require("id", as: UUID.self)
        return await self.repository.get(id: id)
    }

    struct CreateItemRequest: Decodable {
        let name: String
        let description: String
    }

    @Sendable
    func create(_ request: Request, context: Context) async throws
        -> EditedResponse<Item>
    {
        let itemRequest = try await request.decode(
            as: CreateItemRequest.self, context: context)
        let item = try await self.repository.create(
            name: itemRequest.name, description: itemRequest.description)
        return .init(status: .created, response: item)
    }

    struct UpdateItemRequest: Decodable {
        let name: String?
        let description: String?
    }

    @Sendable
    func update(_ request: Request, context: Context) async throws -> Item {
        let id = try context.parameters.require("id", as: UUID.self)
        let itemRequest = try await request.decode(
            as: UpdateItemRequest.self, context: context)

        let updatedItem = try await self.repository.update(
            id: id, name: itemRequest.name, description: itemRequest.description
        )

        guard let item = updatedItem else {
            throw HTTPError(.notFound)
        }

        return item
    }

    @Sendable
    func delete(_ request: Request, context: Context) async throws
        -> HTTPResponse.Status
    {
        let id = try context.parameters.require("id", as: UUID.self)
        let deleted = await self.repository.delete(id: id)
        guard deleted else {
            throw HTTPError(.notFound)
        }
        return .ok
    }
}
