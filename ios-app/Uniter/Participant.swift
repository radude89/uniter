//
//  Participant.swift
//  Uniter
//
//  Created by Radu Dan on 15/08/2020.
//

import Foundation

struct Participant: Codable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    
    init(id: UUID = UUID(),
         firstName: String = "John",
         lastName: String = "Doe") {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension Participant {
    var imageName: String {
        "\(firstName.lowercased())-\(lastName.lowercased())"
    }
    
    var displayName: String {
        "\(firstName) \(lastName)"
    }
}
