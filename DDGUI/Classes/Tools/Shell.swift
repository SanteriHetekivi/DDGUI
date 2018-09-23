//
//  Shell.swift
//  DDGUI
//
//  Created by Santeri Hetekivi on 23/09/2018.
//  Copyright © 2018 Santeri Hetekivi. All rights reserved.
//

import Cocoa

/// <#Description#>
class Shell {
    /// Command to run on shell.
    private let cmd: String
    /// Command url fot the Proccess
    private let url: URL
    /// Command arguments as String array.
    private let args: [String]
    /// Function to call when command succeeds.
    private let onSuccess: ((String) -> Void)
    /// Function to call when command fails.
    private let onFailure: ((String) -> Void)
    /// Pipe for command output.
    private let outPipe: Pipe = Pipe()
    /// Pipe for command errors.
    private let errPipe: Pipe = Pipe()
    /// Proccess for running command.
    private let task: Process = Process()
    
    /// Initialize Shell class with all needed parameters.
    ///
    /// - Parameters:
    ///   - cmd: Command to run on shell.
    ///   - args: Command arguments as String array.
    ///   - onSuccess: Function to call when command succeeds.
    ///   - onFailure: Function to call when command fails.
    /// - Throws: Error when initializing fails.
    init(cmd: String, args: [String] = [], onSuccess: @escaping ((String) -> Void), onFailure: @escaping ((String) -> Void)) throws
    {
        self.cmd = cmd
        self.args = args
        self.onSuccess = onSuccess;
        self.onFailure = onFailure;
        self.url = URL(fileURLWithPath: self.cmd)
        self.task.standardError = self.errPipe
        self.task.standardOutput = self.outPipe
        self.task.executableURL = self.url
        self.task.arguments = self.args
        self.task.terminationHandler = self.terminationHandler
    }
    
    /// Run the initialized shell command as a Process.
    ///
    /// - Throws: Error from the Proccess.
    func run() throws -> Void
    {
        try self.task.run()
    }
    
    /// Handles termination of the shell Process.
    ///
    /// - Parameter proccess: Proccess that was terminated.
    private func terminationHandler(proccess: Process) -> Void
    {
        let function: ((String) -> Void)
        let pipe: Pipe
        if proccess.terminationStatus == 0
        {
            function = self.onSuccess
            pipe = self.outPipe
        }
        else
        {
            function = self.onFailure
            pipe = self.errPipe
        }
        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        let nsOutput = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let output: String = (nsOutput == nil) ? "NULL" : nsOutput! as String
        
        function(output);
    }
}
