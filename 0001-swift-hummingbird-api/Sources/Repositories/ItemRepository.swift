import Foundation

protocol ItemRepository: Sendable {
    func list() async -> [Item]
    func create(name: String, description: String) async throws -> Item
    func get(id: UUID) async -> Item?
    func update(id: UUID, name: String?, description: String?) async throws
        -> Item?
    func delete(id: UUID) async -> Bool
}

actor ItemMemoryRepository: ItemRepository {
    private var items: [UUID: Item]

    init() {
        self.items = [:]
    }

    func list() async -> [Item] {
        return Array(items.values)
    }

    func create(name: String, description: String) async throws -> Item {
        let item = Item(id: UUID(), name: name, description: description)
        self.items[item.id] = item
        return item
    }

    func get(id: UUID) async -> Item? {
        return self.items[id]
    }

    func update(id: UUID, name: String?, description: String?) async throws
        -> Item?
    {
        if var item = self.items[id] {
            if let name {
                item.name = name
            }
            if let description {
                item.description = description
            }
            self.items[id] = item
            return item
        }
        return nil
    }

    func delete(id: UUID) async -> Bool {
        guard self.items[id] != nil else {
            print("not found")
            return false
        }
        print("Found")
        self.items[id] = nil
        return true
    }

}
