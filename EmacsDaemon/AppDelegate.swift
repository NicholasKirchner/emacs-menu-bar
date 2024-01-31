//
//  AppDelegate.swift
//  Emacs Menu Bar
//
//  Created by Nicholas Kirchner on 1/20/24.
//

import Cocoa

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var logFile: URL!
    private var serverPath: String!
    private var emacsPath: String!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        logFile = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Logs/emacs-menu-bar.log")
        serverPath = "\(NSHomeDirectory())/.emacs.d/server"
        emacsPath = "/Applications/Emacs.app/Contents/MacOS/bin/"
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let icon = NSImage(named: "StatusIcon")!
        let resizedIcon = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { (dstRect) -> Bool in
            icon.draw(in: dstRect)
            return true
        }
        if let button = statusItem.button {
            button.image = resizedIcon
        }
        
        setupMenus()
    }
    
    func setupMenus() {
        let menu = NSMenu()
        
        menu.items = [
            NSMenuItem(title: "New Frame", action: #selector(doNew), keyEquivalent: "n"),
            NSMenuItem(title: "Start Daemon", action: #selector(doStart), keyEquivalent: "o"),
            .separator(),
            NSMenuItem(title: "View Logs", action: #selector(viewLogs), keyEquivalent: "l"),
            NSMenuItem(title: "Restart Daemon", action: #selector(doRestart), keyEquivalent: "r"),
            NSMenuItem(title: "Stop Daemon", action: #selector(doStop), keyEquivalent: "w"),
            .separator(),
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        ]
        statusItem.menu = menu
    }
    
    @objc func viewLogs() {
        NSWorkspace.shared.open(logFile)
    }
    
    @objc func doNew() throws -> String {
        writeToLog("Creating new GUI Emacs Frame\n")
        let output = try emacsShellCommand("emacsclient", ["-c", "-n", "--socket-name=\(serverPath ?? "")/server"])
        return output
    }
    
    @objc func doStart() throws -> String {
        writeToLog("Finding your default login shell and environment\n")
        let shell = try shellCommand("/bin/sh", ["-c", "dscl . -read \(NSHomeDirectory()) UserShell | sed \"s/UserShell: //\""]).trimmingCharacters(in: .whitespacesAndNewlines)
        writeToLog("Starting Daemon\n")
        let output = try shellCommand(shell, ["-l", "-c", "emacs --daemon"])
        return output
    }
    
    @objc func doRestart() {
        
    }
    
    @objc func doStop() throws -> String {
        writeToLog("Stopping Daemon\n")
        let output = try emacsShellCommand("emacsclient", ["-e",  "(save-buffers-kill-emacs)", "--socket-name=\(serverPath ?? "")/server"])
        return output
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func emacsShellCommand(_ command: String, _ args: [String]) throws -> String {
        return try shellCommand("\(emacsPath ?? "")/\(command)", args)
    }
    
    func shellCommand(_ command: String, _ args: [String]) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = args
        task.executableURL = URL(fileURLWithPath: command)
        task.standardInput = nil
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        writeToLog(output)
            
        return output
    }
    
    func writeToLog(_ message: String) {
        let data = Data(message.utf8)
        
        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
            else {
                print("Can't open existing log file")
            }
        }
        else {
            try? data.write(to: logFile, options: .atomicWrite)
        }
    }
}
