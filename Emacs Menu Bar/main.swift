//
//  main.swift
//  Emacs Menu Bar
//
//  Created by Nicholas Kirchner on 1/20/24.
//

import Foundation
import Cocoa

// 1
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 2
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
