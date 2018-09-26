//
//  ViewController.swift
//  DDGUI
//
//  Created by Santeri Hetekivi on 23/09/2018.
//  Copyright © 2018 Santeri Hetekivi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    /// Text field for writing out the DD-command.
    @IBOutlet var CommandField: NSTextField!
    
    /// Disk selector.
    @IBOutlet var DiskSelect: NSPopUpButtonCell!
    
    /// Get currently selected disk path.
    private var DiskPath: String {
        get {
            let index: Int = DiskSelect.indexOfSelectedItem
            if let diskPath: String = self.diskPaths[index]
            {
                return diskPath
            }
            else
            {
                return "";
            }
        }
    }
    
    /// Path of the disk image.
    private var filePath: String = "";
    /// Accessor for the filePath.
    private var FilePath: String {
        set {
            self.filePath = newValue
            self.buildCommand()
        }
        get {
            return self.filePath;
        }
    }
    
    /// Variable to storing the paths to disks
    private var diskPaths: Dictionary<Int, String> = Dictionary<Int, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateDisks()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /// Action for disk changing
    ///
    /// - Parameter sender: NSPopUpButton that changes.
    @IBAction func diskChanged(_ sender: NSPopUpButton) {
        self.buildCommand()
    }
    
    /// When file selection button is clicked this function is called.
    ///
    /// - Parameter sender: Button that was clicked
    @IBAction func selectFile(_ sender: Any) {
        if let url: URL = NSOpenPanel().selectISO {
            self.FilePath = url.path;
        }
    }
    
    /// Build the DD-command.
    ///
    /// - Returns: DD-command
    @discardableResult private func buildCommand() -> String
    {
        let command: String = "dd if='"+self.FilePath+"' of='"+self.DiskPath+"'"
        CommandField.stringValue = command
        return command
    }
    
    /// Populate the disk select.
    private func populateDisks()-> Void
    {
        DiskSelect.removeAllItems()
        self.diskPaths.removeAll()
        
        /* TODO: Get real disks.
        do
        {
            if let url: URL = NSOpenPanel().selectISO {
                self.FilePath = url.path;
            }
             let browser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.plain-text"])
         
             let shell: Shell = try Shell(cmd: "/bin/df", args: ["-k"], onSuccess: self.onSuccess, onFailure: self.onFailure)
             try shell.run();
        } catch {
            self.onFailure(result: error.localizedDescription)
        }
         */
        
        // Just some dummy data.
        let diskNames: [String] = [
            "test",
            "test2",
            "test3",
        ]
        for (index, value) in diskNames.enumerated()
        {
            self.diskPaths[index] = value
        }
        DiskSelect.addItems(withTitles: diskNames)
    }
    
    
    
    /// Handles onSuccess call for shell-command.
    ///
    /// - Parameter result: Output for the command.
    public func onSuccess(result: String) -> Void
    {
        print("Success:"+result)
    }
    
    /// Handles onFailure call for shell-command.
    ///
    /// - Parameter result: Output for the error.
    public func onFailure(result: String) -> Void
    {
        print("Failure:"+result)
    }

    
}

