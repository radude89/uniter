//
//  ContentView.swift
//  Uniter
//
//  Created by Radu Dan on 11/08/2020.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @ObservedObject var dataLoader = DataLoader()
    @State private var showingWidgetMeetup = false
    
    @State private var selectedMeetup: Meetup?
    
    var body: some View {
        NavigationView {
            List(dataLoader.meetups) { meetup in
                NavigationLink(
                    destination: MeetupView(meetup: meetup, dataLoader: dataLoader)) {
                    Image(meetup.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80, alignment: .center)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.blue, lineWidth: 3)
                                .shadow(radius: 10)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(meetup.name)
                            .font(.headline)
                        Text(meetup.description)
                    }
                }
            }
            .navigationBarTitle("Uniter", displayMode: .inline)
            .onAppear(perform: fetchData)
            .onOpenURL(perform: openURL)
            .sheet(isPresented: $showingWidgetMeetup) {
                if let selectedMeetup = selectedMeetup {
                    MeetupView(meetup: selectedMeetup, dataLoader: dataLoader)
                }
            }
        }
    }
    
    private func fetchData() {
        WidgetCenter.shared.reloadAllTimelines()
        fetchMeetups()
        fetchParticipants()
    }
    
    private func fetchMeetups() {
        dataLoader.fetch(api: "meetups") { (result: Result<[Meetup], LocalError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let meetups):
                    self.dataLoader.meetups = meetups.sorted { $0.name > $1.name }
                    
                case .failure(.generic(let errorMessage)):
                    print(errorMessage)
                }
            }
        }
    }
    
    private func fetchParticipants() {
        dataLoader.fetch(api: "participants") { (result: Result<[Participant], LocalError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let participants):
                    self.dataLoader.participants = participants
                    
                case .failure(.generic(let errorMessage)):
                    print(errorMessage)
                }
            }
        }
    }
    
    private func openURL(_ url: URL) {
        guard let uuid = UUID(uuidString: url.lastPathComponent) else {
            return
        }
        
        guard let meetup = dataLoader.meetups.first(where: { $0.id == uuid }) else {
            return
        }
        
        // buggy
        selectedMeetup = meetup
        showingWidgetMeetup = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
