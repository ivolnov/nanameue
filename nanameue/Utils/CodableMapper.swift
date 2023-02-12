//
//  CodableMapper.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import Foundation

protocol CodableMapper {
    func decodable<Key: Hashable, T: Decodable>(from dict: [Key: Any]) throws -> T
    func dictionary(from encodable: Encodable) throws -> [String: Any]
}

final class CodableMapperImpl: CodableMapper {

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.encoder = encoder
        self.decoder = decoder
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func dictionary(from encodable: Encodable) throws -> [String: Any] {
        let data = try encoder.encode(encodable)
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let dictionary = json as? [String: Any]
        return dictionary ?? [:]
    }
    
    func decodable<Key: Hashable, T: Decodable>(from dict: [Key: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        let decodable = try decoder.decode(T.self, from: data)
        return decodable
    }
}
