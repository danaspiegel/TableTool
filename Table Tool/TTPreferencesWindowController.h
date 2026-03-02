//
//  TTPreferencesWindowController.h
//  Table Tool
//
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTPreferencesWindowController : NSWindowController

+ (instancetype)sharedController;
-(IBAction)showPreferences:(id)sender;

@end
