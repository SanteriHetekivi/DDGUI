//
//  ViewController.swift
//  DDGUI
//
//  Created by Santeri Hetekivi on 23/09/2018.
//  Copyright © 2018 Santeri Hetekivi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /// When buttons is clicked this function is called.
    /// Runs shell-command.
    ///
    /// - Parameter sender: Button that was clicked
    @IBAction func buttonClicked(_ sender: Any) {
        do
        {
            let shell: Shell = try Shell(cmd: "/bin/df", args: ["-k"], onSuccess: self.onSuccess, onFailure: self.onFailure)
            try shell.run();
        } catch {
            self.onFailure(result: error.localizedDescription)
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

