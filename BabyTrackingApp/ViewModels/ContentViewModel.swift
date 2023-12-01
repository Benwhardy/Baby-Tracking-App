//
//  ContentViewModel.swift
//  BabyTrackingApp
//
//  Created by Ben Hardy on 12/1/23.
//

import Foundation
import FirebaseFirestore


class ContentViewModel: ObservableObject {
    @Published var lastThreeFeedings: [FeedingSession] = []

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
