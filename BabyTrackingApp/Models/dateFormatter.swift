//
//  dateFormatter.swift
//  BabyTrackingApp
//
//  Created by Ben Hardy on 12/1/23.
//

import Foundation

var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}
