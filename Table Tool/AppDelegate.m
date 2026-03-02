//
//  AppDelegate.m
//  Table Tool
//
//  Created by Andreas Aigner on 06.07.15.
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "TTPreferencesWindowController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        TTShowLineNumbersKey: @YES,
        TTTableFontSizeKey: @13
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)showPreferences:(id)sender {
    [[TTPreferencesWindowController sharedController] showWindow:sender];
}

@end
