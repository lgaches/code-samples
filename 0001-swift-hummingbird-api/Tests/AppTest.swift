import Foundation
import Hummingbird
import HummingbirdTesting
import Testing

@testable import App

struct AppTests {

    @Test
    func testCreate() async throws {
        let itemRepository: ItemRepository = ItemMemoryRepository()

        let router = Router()

        ItemController<BasicRequestContext>(repository: itemRepository)
            .addRoutes(to: router.group("api/items"))

        let app = Application(router: router)

        try await app.test(.router) { client in
            try await client.execute(
                uri: "/api/items", method: .post,
                body: ByteBuffer(
                    string: #"{"name":"book", "description":"a nice book"}"#)
            ) { response in
                #expect(response.status == .created)
                let body = response.body
                let result = try JSONDecoder().decode(Item.self, from: body)
                #expect(result.name == "book")
                #expect(result.description == "a nice book")
            }
        }
    }
}
