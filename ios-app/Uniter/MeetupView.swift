//
//  MeetupView.swift
//  Uniter
//
//  Created by Radu Dan on 15/08/2020.
//

import SwiftUI

struct MeetupView: View {
    let meetup: Meetup
    @ObservedObject var dataLoader: DataLoader
    
    @State private var participants: [Participant] = []
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(meetup.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.7)
                        .padding(.top)
                    
                    Text(meetup.name)
                        .font(.headline)
                        .padding(.top)
                    
                    Text(meetup.description)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text(Dummy.text)
                        .padding()
                    
                    List(participants) { participant in
                        NavigationLink(
                            destination: ParticipantView(participant: participant, dataLoader: dataLoader)) {
                            Image(participant.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text(participant.displayName)
                                    .font(.headline)
                                Text("Swifter")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text(meetup.name), displayMode: .inline)
        .onAppear(perform: fetchParticipants)
    }
    
    private func fetchParticipants() {
        dataLoader.fetch(api: "meetups/\(meetup.id)/participants") { (result: Result<[Participant], LocalError>) in
            switch result {
            case .success(let participants):
                self.participants = participants
                
            case .failure(.generic(let errorMessage)):
                print(errorMessage)
            }
        }
    }
}

struct MeetupView_Previews: PreviewProvider {
    static var previews: some View {
        MeetupView(meetup: Meetup(), dataLoader: DataLoader())
    }
}
