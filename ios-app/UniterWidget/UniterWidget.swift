//
//  UniterWidget.swift
//  UniterWidget
//
//  Created by Radu Dan on 15/08/2020.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    public typealias Entry = LastMeetup
    
    func placeholder(with: Context) -> LastMeetup {
        let meetup = Meetup(id: UUID(),
                            name: "iOS Meetup",
                            description: "Swift meetup",
                            createdAt: Date())
        return LastMeetup(date: Date(), meetup: meetup)
    }
    
    public func snapshot(with context: Context, completion: @escaping (Entry) -> ()) {
        let meetup = Meetup(id: UUID(),
                            name: "iOS Meetup",
                            description: "Swift meetup",
                            createdAt: Date())
        let lastMeetup = LastMeetup(date: Date(), meetup: meetup)
        completion(lastMeetup)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<LastMeetup>) -> ()) {
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        
        let dataLoader = DataLoader()
        dataLoader.fetch(api: "meetups") { (result: Result<[Meetup], LocalError>) in
            switch result {
            case .success(var meetups):
                meetups.sort { $0.createdAt!.compare($1.createdAt!) == .orderedDescending }
                let lastMeetup = LastMeetup(date: currentDate, meetup: meetups.first!)
                let timeline = Timeline(entries: [lastMeetup], policy: .after(nextUpdateDate))
                completion(timeline)
                
            case .failure(.generic(let errorMessage)):
                print(errorMessage)
                let meetup = Meetup(id: UUID(),
                                    name: "Cocoa heads 6",
                                    description: "Swift meetup",
                                    createdAt: Date())
                let lastMeetup = LastMeetup(date: currentDate, meetup: meetup)
                let timeline = Timeline(entries: [lastMeetup], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
}

struct LastMeetup: TimelineEntry {
    public let date: Date
    public let meetup: Meetup
    
    var relevance: TimelineEntryRelevance? {
        TimelineEntryRelevance(score: 100)
    }
}

struct PlaceholderView : View {
    var body: some View {
        Text("Loading last meetup")
    }
}

struct UniterWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text(entry.date, style: .time)
        VStack {
            Image(entry.meetup.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Text(entry.meetup.name)
                .font(.headline)
            
            Text(entry.meetup.description)
            
            Text("Prepare to rumble at \(Self.format(date:entry.date))")
                .font(.footnote)
        }
        .widgetURL(URL(string: "uniter://meetup/\(entry.meetup.id)"))
    }
    
    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

@main
struct UniterWidget: Widget {
    private let kind: String = "UniterWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            UniterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Meetups")
        .description("This is an example widget.")
    }
}
