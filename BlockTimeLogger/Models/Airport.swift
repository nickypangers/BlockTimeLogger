import Foundation
import GRDB

struct Airport: Identifiable, Codable, Equatable {
    var id: Int
    var name: String
    var icao: String
    var iata: String

    init(id: Int = 0, name: String, icao: String, iata: String) {
        self.id = id
        self.name = name
        self.icao = icao
        self.iata = iata
    }
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
