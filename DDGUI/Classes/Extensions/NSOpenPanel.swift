//
//  NSOpenPanel.swift
//  DDGUI
//
//  Created by Santeri Hetekivi on 26/09/2018.
//  Copyright © 2018 Santeri Hetekivi. All rights reserved.
//

import Cocoa

// MARK: - Extension forNSOpenPanel.
extension NSOpenPanel {
    /// Select ISO file.
    var selectISO: URL? {
        title = "Select ISO"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["iso"]
        return runModal() == .OK ? urls.first : nil
    }
}
