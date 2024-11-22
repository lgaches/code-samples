import Foundation
import Hummingbird

let itemRepository: ItemRepository = ItemMemoryRepository()

let router = Router()

ItemController<BasicRequestContext>(repository: itemRepository).addRoutes(
    to: router.group("api/items"))

let app = Application(router: router)

try await app.run()
