//
//  AppTips.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import TipKit

/// Step 1 — log shocks and deliberate risks from Home.
struct AddEventTip: Tip {
    var title: Text {
        Text("Step 1 · Log an event")
    }
    
    var message: Text? {
        Text("Capture a shock or a chosen risk. Black Swan classifies it and suggests protections.")
    }
    
    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
    
    var options: [TipOption] {
        [MaxDisplayCount(3)]
    }
}

/// Step 2 — open Fragility insights from the toolbar.
struct FragilityTip: Tip {
    var title: Text {
        Text("Step 2 · Check fragility")
    }
    
    var message: Text? {
        Text("See your score, risk themes, and how exposure shifts week to week.")
    }
    
    var image: Image? {
        Image(systemName: "chart.line.uptrend.xyaxis")
    }
    
    var options: [TipOption] {
        [MaxDisplayCount(3)]
    }
}

/// Step 3 — weekly review ritual.
struct WeeklyReviewTip: Tip {
    var title: Text {
        Text("Step 3 · Weekly review")
    }
    
    var message: Text? {
        Text("Summarize the last 7 days — focus, wins, and open protections.")
    }
    
    var image: Image? {
        Image(systemName: "calendar")
    }
    
    var options: [TipOption] {
        [MaxDisplayCount(3)]
    }
}

/// Step 4 — pre-mortem before the next surprise.
struct PreMortemTip: Tip {
    var title: Text {
        Text("Step 4 · Run a pre-mortem")
    }
    
    var message: Text? {
        Text("Imagine the failure first, then build buffers before impact.")
    }
    
    var image: Image? {
        Image(systemName: "shield.lefthalf.filled")
    }
    
    var options: [TipOption] {
        [MaxDisplayCount(3)]
    }
}
