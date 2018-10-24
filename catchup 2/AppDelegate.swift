//
//  AppDelegate.swift
//  Catchup
//
//  Created by Black Bear on 04.05.16.
//  Copyright © 2016 Teal Systems. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //
    // outlets to connect to InterfaceBuilder
    //
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu : NSMenu!
    @IBOutlet weak var start : NSMenuItem!
    @IBOutlet weak var stop : NSMenuItem!
    @IBOutlet weak var pause : NSMenuItem!
    @IBOutlet weak var interrupt : NSMenuItem!
    @IBOutlet weak var resume : NSMenuItem!
    @IBOutlet weak var about : NSMenuItem!
    @IBOutlet weak var quit : NSMenuItem!
    @IBOutlet weak var shortBreak : NSMenuItem!
    @IBOutlet weak var longBreak : NSMenuItem!
    @IBOutlet weak var information : NSMenuItem!
    
    //
    // internal const
    //
    let workDuration:Int = 25;
    let shortBreakDuration:Int = 5;
    let longBreakDuration:Int = 15;
    let changeOrange:Int = 5;
    let intervalTime:TimeInterval = 60;
    
    //
    // internal variables
    //
    var statusItem:NSStatusItem = NSStatusItem()
    var aTimer:Timer = Timer()
    var aBreakTimer:Timer = Timer()
    var aCounter:Int = 0
    var aBreakCounter:Int = 0
    
    //
    // standard functions (overrides)
    //
    override func awakeFromNib() {
        // Insert code here to initialize your application
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        statusItem.menu = menu;
        statusItem.highlightMode = true;
        
        menu.autoenablesItems = false;
        about.isEnabled = true;
        
        stopFunction();
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        //self.window!.orderOut(self);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func setInfoText(aInfoString: NSString, aInfoColor: NSColor) {
        let finalInfoString = "State: " + (aInfoString as String);
        let colorTitle:NSAttributedString = NSAttributedString(string: finalInfoString, attributes: [NSAttributedString.Key.foregroundColor: aInfoColor]);
        // Version next to the icon
        /*statusItem.attributedTitle = colorTitle;*/
        
        // Version as string in the menu
        //information.title = aInfoString as String;
        information.attributedTitle = colorTitle;
    }
    
    //
    // internal functions
    //
    func playSound() {
        // Basso
        // Blow
        // Bottle
        // Frog
        // Funk
        // Glass
        // Hero
        // Morse
        // Ping
        // Pop
        // Purr
        // Sosumi
        // Submarine
        // Tink
        
        NSSound(named:"Hero")?.play();
    }
    
    @objc func tick() {
        // decrease the counter
        aCounter -= 1;
        
        // variable for the font color
        var titleColor = NSColor.green;
        
        // update icon and text color
        if (aCounter > changeOrange)
        {
            changeIcon(iconName: "tomato_green-512.png");
        }
        else if (aCounter > 0)
        {
            changeIcon(iconName: "tomato_orange-512.png");
            titleColor = NSColor.orange;
        }
        else
        {
            changeIcon(iconName: "tomato_red-512.png");
            titleColor = NSColor.red;
        }
        
        // play sound if counter is zero
        if (aCounter == 0){
            playSound();
        }
        
        // update text
        let title:NSString = NSString.localizedStringWithFormat("%d Minutes to go", aCounter);
        setInfoText(aInfoString: title, aInfoColor: titleColor);
    }

    @objc func breakTick() {
        // decrease the counter
        aBreakCounter -= 1;
        
        // variable for the font color
        var titleColor = NSColor.black;
        
        // update icon and text color
        if (aBreakCounter <= 0)
        {
            titleColor = NSColor.red;
        }
        
        // play sound if counter is zero
        if (aBreakCounter == 0){
            playSound();
        }
        
        // update text
        let title:NSString = NSString.localizedStringWithFormat("break (%d Minutes left)", aBreakCounter)
        setInfoText(aInfoString: title, aInfoColor: titleColor);
        
        // change the icon
        changeIcon(iconName: "tomato_empty-512.png");
    }
    
    // control the different user entries
    // work time can be green (25, 20, 15, 10, 5 Minutes)
    //                  orange (5, 4, 3, 2, 1, 0 Minutes)
    //                  red (overtime)
    // pause time can be empty (5, 4, 3, 2, 1, 0 Minutes)
    //                   red (overtime)
    // interruptions are with a red flash
    //
    
    // helper method to change the icon
    func changeIcon(iconName: NSString) {
        let icon:NSImage = NSImage(named: iconName as String)!;
        if (icon.isValid) {
            icon.size = NSMakeSize(21, 21);
            statusItem.image = icon;
        }
    }

    // helper method to disable all menu items
    func disableMenuItems() {
        information.isEnabled = false;
        start.isEnabled = false;
        stop.isEnabled = false;
        pause.isEnabled = false;
        interrupt.isEnabled = false;
        resume.isEnabled = false;
    }
    
    //
    // functions that respond to actions
    //
    // start the work time
    @IBAction func start(sender: NSButton) {
        NSLog("start the work time");
    
        // disable all menu items that could change the state machine
        disableMenuItems();
        stop.isEnabled = true;
        interrupt.isEnabled = true;
        pause.isEnabled=true;
    
        // stop the break time
        aBreakTimer.invalidate();
    
        // set counter
        aCounter = workDuration + 1;
    
        // change the state
        // as intermediate solution: start the timer
        aTimer = Timer.scheduledTimer(timeInterval: intervalTime, target: self, selector: #selector(AppDelegate.tick), userInfo: nil, repeats: true);
        aTimer.fire();
    }
    
    // stop the work time
    @IBAction func stop(sender: NSButton) {
        stopFunction();
    }
    
    //
    // test function
    //
    func stopFunction() {
        NSLog("stop the work time");
        
        // disable all menu items that could change the state machine
        disableMenuItems();
        start.isEnabled = true;
        
        // stop the work time
        aTimer.invalidate();
        
        // stop the break time
        aBreakTimer.invalidate();
        
        // update the title
        setInfoText(aInfoString: "stopped", aInfoColor: NSColor.gray);
        
        // change the icon
        changeIcon(iconName: "tomato_empty-512.png");
    }
    
    // take a short break
    @IBAction func shortBreak(sender: NSButton) {
        pause(duration: shortBreakDuration);
    }
    
    // take a long break
    @IBAction func longBreak(sender: NSButton) {
        pause(duration: longBreakDuration);
    }
    
    // break action function with argument regarding the duration
    func pause(duration: Int) {
        NSLog("start the break time");
    
        // disable all menu items that could change the state machine
        disableMenuItems();
        stop.isEnabled = true;
        start.isEnabled = true;
    
        // stop the work time and start the break
        aTimer.invalidate();
    
        // set counter
        aBreakCounter = duration + 1;
        
        aBreakTimer = Timer.scheduledTimer(timeInterval: intervalTime, target: self, selector: #selector(AppDelegate.breakTick), userInfo: nil, repeats: true);
        aBreakTimer.fire();
    }
    
    // action to interrupt
    @IBAction func interrupt(sender: NSButton) {
        NSLog("interrupt the work time");
    
        // disable all menu items that could change the state machine
        disableMenuItems();
        resume.isEnabled = true;
        stop.isEnabled = true;
        pause.isEnabled = true;
    
        // stop the timer and start the interruption
        aTimer.invalidate();
    
        // update the title
        setInfoText(aInfoString: "interrupted", aInfoColor: NSColor.red);
    
        // change the icon
        changeIcon(iconName: "tomato_flash-512.png");
    }

    // action to resume
    @IBAction func resume(sender: NSButton) {
        NSLog("resume after the interruption");
    
        // disable all menu items that could change the state machine
        disableMenuItems();
        stop.isEnabled = true;
        interrupt.isEnabled = true;
        pause.isEnabled = true;
    
        // increase the counter by one due the fact that we fire immediately after the resume
        aCounter += 1;
    
        // resume the timer and fire once to set the icon correctly
        aTimer = Timer.scheduledTimer(timeInterval: intervalTime, target: self, selector: #selector(AppDelegate.tick), userInfo: nil, repeats: true);
        aTimer.fire();
    }

    // show the about screen
    @IBAction func about(sender: NSButton) {
        NSApplication.shared.orderFrontStandardAboutPanel(self);
    }


    // quit the application
    @IBAction func quit(sender: NSButton) {
        NSApplication.shared.terminate(nil);
    }
}

