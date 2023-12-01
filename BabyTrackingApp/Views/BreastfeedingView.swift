//
//  BreastfeedingView.swift
//  BabyTrackingApp
//
//  Created by Ben Hardy on 12/1/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore



struct BreastfeedingView: View {
    @State private var selectedSide: String = "Left"
    @State private var timerIsRunning = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var timer: Timer? = nil
    @State private var showElapsedTime = false
    @State private var totalElapsedTime: TimeInterval = 0


    
    var body: some View {
            VStack {
                if showElapsedTime {
                    Text("Timer: \(formatDuration(startTime, endTime))")
                }

                HStack {
                    Button(action: {
                        if timerIsRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(timerIsRunning ? "Stop" : "Start")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100) // Set the size of the circle
                            .background(timerIsRunning ? Color.red : Color.green) // Red for stop, green for start
                            .clipShape(Circle()) // Make the button circular
                            .shadow(radius: 10) // Optional: adds a shadow effect
                    }

                    Button("Reset") {
                        resetTimer()
                    }
                    .disabled(!showElapsedTime)
                }

                HStack {
                    Button("Left") {
                        selectedSide = "Left"
                    }
                    .foregroundColor(selectedSide == "Left" ? .blue : .gray)
                    
                    Button("Right") {
                        selectedSide = "Right"
                    }
                    .foregroundColor(selectedSide == "Right" ? .blue : .gray)
                }
                
                Divider()

                Button("Save Session") {
                    saveSession()
                }
            }
        }
    
    
   
    
    func startTimer() {
        if !timerIsRunning {
            let currentTime = Date()
            startTime = Date(timeInterval: -totalElapsedTime, since: currentTime)
        }
        
        timerIsRunning = true
        showElapsedTime = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.endTime = Date()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timerIsRunning = false
        totalElapsedTime = endTime.timeIntervalSince(startTime)
    }

    func resetTimer() {
        timer?.invalidate()
        timerIsRunning = false
        showElapsedTime = false
        startTime = Date()
        endTime = Date()
        totalElapsedTime = 0
    }

        func saveSession() {
            let db = Firestore.firestore()
            db.collection("feeding").addDocument(data: [
                "side": selectedSide,
                "startTime": Timestamp(date: startTime),
                "endTime": Timestamp(date: endTime)
            ]) { error in
                if let e = error {
                    print("There was an issue saving data to Firestore. \(e.localizedDescription)")
                } else {
                    print("Successfully saved data.")
                }
            }
        }


private func formatDuration(_ start: Date, _ end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct BreastfeedingView_Previews: PreviewProvider {
    static var previews: some View {
        BreastfeedingView()
    }
}
