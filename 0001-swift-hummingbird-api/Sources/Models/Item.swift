import Foundation
import Hummingbird

struct Item: ResponseCodable {
    let id: UUID
    var name: String
    var description: String
}
