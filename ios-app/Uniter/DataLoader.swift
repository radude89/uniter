//
//  DataLoader.swift
//  Uniter
//
//  Created by Radu Dan on 15/08/2020.
//

import Foundation

final class DataLoader: ObservableObject {
    private enum Key: String {
        case meetups
        case participants
    }
    
    @Published var meetups: [Meetup] {
        didSet {
            guard let encodedMeetups = try? JSONEncoder().encode(meetups) else {
                return
            }
            
            UserDefaults.standard.set(encodedMeetups, forKey: Key.meetups.rawValue)
        }
    }
    
    @Published var participants: [Participant] {
        didSet {
            guard let encodedParticipants = try? JSONEncoder().encode(participants) else {
                return
            }
            
            UserDefaults.standard.set(encodedParticipants, forKey: Key.participants.rawValue)
        }
    }
    
    init() {
        if let meetupsData = UserDefaults.standard.data(forKey: Key.meetups.rawValue),
           let storedMeetups = try? JSONDecoder().decode([Meetup].self, from: meetupsData) {
            meetups = storedMeetups
        } else {
            meetups = []
        }
        
        if let participantsData = UserDefaults.standard.data(forKey: Key.participants.rawValue),
           let storedParticipants = try? JSONDecoder().decode([Participant].self, from: participantsData) {
            participants = storedParticipants
        } else {
            participants = []
        }
    }
}

extension DataLoader {
    func fetch<T: Decodable>(api: String,
                             completion: @escaping (Result<[T], LocalError>) -> Void) {
        let url = URL(string: "http://localhost:8080/api/\(api)")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(LocalError.generic(error.localizedDescription)))
                return
            }
            
            guard let data = data, data.isEmpty == false else {
                completion(.failure(LocalError.generic("Empty data")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let resources = try decoder.decode([T].self, from: data)
                completion(.success(resources))
            } catch {
                completion(.failure(LocalError.generic(error.localizedDescription)))
            }
        }
        .resume()
    }
}

enum LocalError: Error {
    case generic(String)
}

enum Dummy {
    static let text = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ac mi massa. Praesent consectetur libero in metus vestibulum, ac vulputate tortor rhoncus. Donec ultricies erat nisi, non consequat sapien hendrerit in. Proin elementum sapien elit, at placerat libero porta ut. Ut elementum interdum turpis sed bibendum. Nam rhoncus nibh metus, eget tristique magna facilisis quis. Vestibulum dolor dolor, accumsan eget gravida vitae, fringilla vitae dui. Nunc sed libero vel justo sollicitudin convallis. Proin ac turpis pretium augue scelerisque tincidunt at rutrum velit. Integer vel bibendum turpis, sagittis euismod ante. Nunc finibus risus a condimentum aliquet. Sed id sollicitudin lectus.

    Etiam rutrum nisi nisl, id congue ex tempus non. Fusce tristique porttitor ante, eget blandit ligula ornare quis. Duis interdum ipsum eu posuere eleifend. Quisque tempor ultricies malesuada. Donec varius id nunc quis pulvinar. Nulla erat justo, interdum malesuada tortor eget, ultricies rhoncus orci. Integer semper, ex quis tincidunt molestie, magna sapien suscipit leo, et bibendum arcu enim at massa. Ut varius ultrices nisl, a maximus ipsum accumsan quis. Praesent libero libero, efficitur ullamcorper massa sit amet, accumsan ultricies metus. Quisque et euismod augue. Nam ultrices laoreet felis, placerat fringilla nisi faucibus eget. Aenean ut dui nibh. Suspendisse accumsan accumsan nulla quis varius.
    """
}
