//
//  AppDelegate.swift
//  Emacs Menu Bar
//
//  Created by Nicholas Kirchner on 1/20/24.
//

import Cocoa

//@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var logPath: String!
    private var serverPath: String!
    private var emacsPath: String!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
            styleMask: [.miniaturizable, .closable, .resizable, .titled],
            backing: .buffered, defer: false)
        window.center()
        window.title = "No Storyboard Window"
        window.makeKeyAndOrderFront(nil)
        
        logPath = "\(NSHomeDirectory())/Library/Logs/emacs-menu-bar.log"
        serverPath = "\(NSHomeDirectory())/.emacs.d/server"
        emacsPath = "/Applications/Emacs.app/Contents/MacOS/bin/"
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "1.circle", accessibilityDescription: "1")
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
        NSWorkspace.shared.open(NSURL.fileURL(withPath: logPath))
    }
    
    @objc func doNew() throws -> String {
        NSLog("Entered doNew")
        let output = try emacsShellCommand("emacsclient", ["-c", "-n", "--socket-name=\(serverPath ?? "")/server"])
        NSLog(output)
        return output
    }
    
    @objc func doStart() throws -> String {
        NSLog("Entered doStart")
        let shell = try shellCommand("/bin/sh", ["-c", "dscl . -read \(NSHomeDirectory()) UserShell | sed \"s/UserShell: //\""]).trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog(shell)
        let output = try shellCommand(shell, ["-l", "-c", "emacs --daemon"])
        NSLog(output)
        return output
    }
    
    @objc func doRestart() {
        
    }
    
    @objc func doStop() throws -> String {
        NSLog("Entered doStop")
        let output = try emacsShellCommand("emacsclient", ["-e",  "(save-buffers-kill-emacs)", "--socket-name=\(serverPath ?? "")/server"])
        NSLog(output)
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
            
        return output
    }
}
