//
//  Roadbounce.swift
//  Roadbounce
//
//  Created by Sidharth Choudhary on 22/02/22.
//

import WidgetKit
import SwiftUI
import Intents
import CoreMotion

struct Provider: IntentTimelineProvider {
    var accData: CMAccelerometerData?=nil
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), accData: accData,configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let accData: CMAccelerometerData?=nil
        let entry = SimpleEntry(date: Date(),accData: accData, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        var accData: CMAccelerometerData?=nil
        let manager = CMMotionManager()
        Timer.scheduledTimer(withTimeInterval: 1,repeats: true){_ in
            accData=manager.accelerometerData
        }
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, accData: accData,configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let accData: CMAccelerometerData?
    let configuration: ConfigurationIntent
}

struct RoadbounceEntryView : View {
    var entry: Provider.Entry
    private var AccDataView: some View {
        Text(String(format: "%.2f", entry.accData?.acceleration.x as! CVarArg))
    }
    
    private var NoDataView: some View {
        Text("No Data found! Go to the Flutter App")
    }
        
    var body: some View {
        if(entry.accData == nil)
        {
            NoDataView
        } else
        {
            AccDataView
        }
    }
}

@main
struct Roadbounce: Widget {
    let kind: String = "Roadbounce"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            RoadbounceEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Roadbounce_Previews: PreviewProvider {
    static var previews: some View {        RoadbounceEntryView(entry: SimpleEntry(date: Date(), accData: nil, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
