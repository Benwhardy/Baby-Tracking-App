//
//  ContentView.swift
//  BabyTrackingApp
//
//  Created by Ben Hardy on 12/1/23.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var lastThreeFeedings: [FeedingSession] = []

    var body: some View {
        NavigationView {
            VStack {
                // Header Section
                Text("Baby Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Spacer().frame(height: 50)

                // Main Features
                VStack(spacing: 20) {
                    NavigationLink(destination: BreastfeedingView()) {
                        FeatureButton(title: "Start Breastfeeding", iconName: "heart.circle")
                    }
                    // Add more features as needed
                }

                Spacer().frame(height: 50)
                NavigationLink(destination: AllFeedingsView()) {
                                   FeatureButton(title: "View All Feedings", iconName: "list.bullet")
                               }
                

                VStack(alignment: .leading) {
                        Text("Last Three Feedings")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center) // Center the heading
                        Spacer().frame(height: 50)
                        ForEach(lastThreeFeedings, id: \.id) { feeding in
                            HStack {
                                Text("Start: \(feeding.startTime, formatter: dateFormatter)")
                                Spacer()
                                Text("Side: \(feeding.side)")
                                Spacer()
                                Text("Duration: \(feeding.durationString)")
                            }
                            Spacer().frame(height: 50)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .padding()
            .onAppear {
                fetchLastThreeFeedings()
            }
        }
    }

    func fetchLastThreeFeedings() {
        let db = Firestore.firestore()
        db.collection("feeding")
            .order(by: "startTime", descending: true)
            .limit(to: 3)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Error getting documents: \(e.localizedDescription)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        self.lastThreeFeedings = snapshotDocuments.map { doc in
                            let data = doc.data()
                            return FeedingSession(
                                id: doc.documentID,
                                side: data["side"] as? String ?? "",
                                startTime: (data["startTime"] as? Timestamp)?.dateValue() ?? Date(),
                                endTime: (data["endTime"] as? Timestamp)?.dateValue() ?? Date()
                            )
                        }
                    }
                }
            }
    }
}

struct FeedingSession: Identifiable {
    let id: String
    let side: String
    let startTime: Date
    let endTime: Date

    var durationString: String {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return "\(hours)h \(minutes)m"
    }
}


struct FeatureButton: View {
    var title: String
    var iconName: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
            
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
