import Foundation
import GRDB

struct Airport: Identifiable, Codable {
    var id: UUID
    var name: String
    var icao: String
    var iata: String
}

extension Airport: EncodableRecord, FetchableRecord {}

extension Airport: TableRecord {}

extension Airport: PersistableRecord {
    func encode(to container: inout PersistenceContainer) throws {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.icao] = icao
        container[Columns.iata] = iata
    }

    init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        icao = row[Columns.icao]
        iata = row[Columns.iata]
    }
}
