//
//  MainWindowController.swift
//  faceTrackingSwift
//
//  Created by Маркі on 18.11.2020.
//

import Cocoa

class MainWindowController: NSWindowController {

    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func loadWindow() {
        self.window = NSWindow(contentRect: NSMakeRect(100, 100, 800, 600), styleMask: [], backing: .buffered, defer: true)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        contentViewController = ViewController()
    }
    
}


// https://stackoverflow.com/questions/38711406/how-to-keep-window-always-on-the-top-with-swift
// https://stackoverflow.com/questions/27396957/keep-window-always-on-top
// https://stackoverflow.com/questions/33845596/window-visible-on-all-spaces-including-other-fullscreen-apps
// https://www.youtube.com/watch?v=vcyA4vTwZcQ&ab_channel=AppleProgramming
