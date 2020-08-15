//
//  ParticipantView.swift
//  Uniter
//
//  Created by Radu Dan on 15/08/2020.
//

import SwiftUI

struct ParticipantView: View {
    let participant: Participant
    @ObservedObject var dataLoader: DataLoader
    
    @State private var meetups: [Meetup] = []
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(participant.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.primary, lineWidth: 1))
                        .padding(.top)
                    
                    HStack {
                        Text(participant.firstName)
                            .font(.largeTitle)
                        
                        Text(participant.lastName)
                            .font(.largeTitle)
                    }
                                        
                    List(meetups) { meetup in
                        Image(meetup.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)

                        VStack(alignment: .leading) {
                            Text(meetup.name)
                                .font(.headline)
                            Text(meetup.description)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text(participant.displayName), displayMode: .inline)
        .onAppear(perform: fetchMeetups)
    }
    
    private func fetchMeetups() {
        dataLoader.fetch(api: "participants/\(participant.id)/meetups") { (result: Result<[Meetup], LocalError>) in
            switch result {
            case .success(let meetups):
                self.meetups = meetups
                
            case .failure(.generic(let errorMessage)):
                print(errorMessage)
            }
        }
    }
}

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantView(participant: Participant(), dataLoader: DataLoader())
    }
}
