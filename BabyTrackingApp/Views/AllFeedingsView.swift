//
//  AllFeedingsView.swift
//  BabyTrackingApp
//
//  Created by Ben Hardy on 12/1/23.
//

import SwiftUI
import FirebaseFirestore

struct AllFeedingsView: View {
    @State private var allFeedings: [FeedingSession] = []

    var body: some View {
        VStack {
            Text("All Feedings")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(allFeedings, id: \.id) { feeding in
                    VStack(alignment: .leading) {
                        Text("Start: \(feeding.startTime, formatter: dateFormatter)")
                        Text("Side: \(feeding.side)")
                        Text("Duration: \(feeding.durationString)")
                    }
                }
                .onDelete(perform: deleteFeeding)
            }
        }
        .onAppear {
            fetchAllFeedings()
        }
    }

    // Function to delete feeding
    private func deleteFeeding(at offsets: IndexSet) {
        offsets.forEach { index in
                // Get the ID of the feeding to delete
                let feedingID = allFeedings[index].id

                // Delete from Firestore
                let db = Firestore.firestore()
                db.collection("feeding").document(feedingID).delete { error in
                    if let e = error {
                        print("Error removing document: \(e.localizedDescription)")
                    } else {
                        print("Document successfully removed!")
                    }
                }

                // Delete from allFeedings state
                allFeedings.remove(atOffsets: offsets)
            }
    }

    func fetchAllFeedings() {
        let db = Firestore.firestore()
        db.collection("feeding")
            .order(by: "startTime", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Error getting documents: \(e.localizedDescription)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        self.allFeedings = snapshotDocuments.map { doc in
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

