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
    
    /// Button for selecting file.
    @IBOutlet var FileSelectButton: NSButton!
    
    /// Button for running the command.
    @IBOutlet var RunButton: NSButton!
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
        if let selectedTitle: String = DiskSelect.titleOfSelectedItem
        {
            // Populate select when select is changed.
            populateDisks()
            DiskSelect.selectItem(withTitle: selectedTitle)
        }
    }
    
    /// When file selection button is clicked this function is called.
    ///
    /// - Parameter sender: Button that was clicked
    @IBAction func selectFile(_ sender: Any) {
        if let url: URL = NSOpenPanel().selectISO {
            self.FilePath = url.path;
            self.FileSelectButton.title = url.lastPathComponent;
        }
    }
    
    /// Build the DD-command.
    ///
    /// - Returns: DD-command
    @discardableResult private func buildCommand() -> String
    {
        let diskPath = self.DiskPath;
        let filePath = self.FilePath;
        
        let command: String = "sudo diskutil unmountDisk '"+self.DiskPath+"' && (sudo dd if='"+self.FilePath+"' of='"+self.DiskPath+"' & echo 'Writing' && sleep 2 && while pgrep ^dd; do sudo kill -INFO $(pgrep ^dd); sleep 1; done)"
        CommandField.stringValue = command
        self.RunButton.isEnabled = !(diskPath.isEmpty || filePath.isEmpty)
        return command
    }
    
    /// Populate the disk select.
    private func populateDisks()-> Void
    {
        DiskSelect.removeAllItems()
        self.diskPaths.removeAll()
        
        // Read mounted volumes.
        if let session = DASessionCreate(kCFAllocatorDefault) {
            let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
            if let mountedVolumes: [URL] = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [])
            {
                var index: Int = 0;
                for volume:URL in mountedVolumes {
                    if let disk: DADisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volume as CFURL) {
                        if let pointer: UnsafePointer<Int8> = DADiskGetBSDName(disk)
                        {
                            // Remove partition from the name.
                            let stringName: NSMutableString = NSMutableString(string: String(cString: pointer))
                            let pattern = "s[0-9]*$"
                            let regex:NSRegularExpression = try! NSRegularExpression(pattern: pattern)
                            regex.replaceMatches(in: stringName, options: .reportProgress, range: NSRange(location: 0,length: stringName.length), withTemplate: "")
                            let diskName:String = stringName as String
                            // Set disks to diskPaths dictonary
                            self.diskPaths[index] = "/dev/"+diskName
                            // and UI select.
                            DiskSelect.addItem(withTitle: volume.lastPathComponent)
                            index += 1
                        }
                    }
                }
            }
        }
    }
    
    /// Run command that was build
    ///
    /// - Parameter sender: Button
    @IBAction func runCommand(_ sender: NSButton) {
        let theASScript: String = "tell app \"Terminal\" to reopen activate do script \""+self.buildCommand()+"\""
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: theASScript) {
            let _: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error)
            if (error != nil) {
                print("error: \(error)")
            }
        }
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

