//
//  Meetup.swift
//  Uniter
//
//  Created by Radu Dan on 15/08/2020.
//

import Foundation

struct Meetup: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let createdAt: Date?
    
    init(id: UUID = UUID(),
         name: String = "Cocoa Heads 1",
         description: String = "We meet to share Swift passions",
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
    }
}

extension Meetup {
    var imageName: String {
        name.replacingOccurrences(of: " ", with: "").lowercased()
    }
}
