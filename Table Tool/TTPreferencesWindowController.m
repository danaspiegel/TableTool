//
//  TTPreferencesWindowController.m
//  Table Tool
//
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "TTPreferencesWindowController.h"
#import "Constants.h"

@interface TTPreferencesWindowController ()
@property (nonatomic, strong) NSButton *fontButton;
@property (nonatomic, strong) NSStepper *fontSizeStepper;
@property (nonatomic, strong) NSTextField *fontSizeLabel;
@end

@implementation TTPreferencesWindowController

+ (instancetype)sharedController {
    static TTPreferencesWindowController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TTPreferencesWindowController alloc] init];
    });
    return shared;
}

- (instancetype)init {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 120)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    window.title = @"Preferences";
    self = [super initWithWindow:window];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    NSView *contentView = self.window.contentView;

    // "Table Font:" label
    NSTextField *fontLabel = [NSTextField labelWithString:@"Table Font:"];
    fontLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:fontLabel];

    // Font button showing current font name
    self.fontButton = [NSButton buttonWithTitle:[self currentFontDisplayName] target:self action:@selector(fontButtonClicked:)];
    self.fontButton.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.fontButton];

    // "Size:" label
    NSTextField *sizeLabel = [NSTextField labelWithString:@"Size:"];
    sizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:sizeLabel];

    // Font size stepper
    self.fontSizeStepper = [[NSStepper alloc] init];
    self.fontSizeStepper.translatesAutoresizingMaskIntoConstraints = NO;
    self.fontSizeStepper.minValue = 6;
    self.fontSizeStepper.maxValue = 72;
    self.fontSizeStepper.increment = 1;
    self.fontSizeStepper.valueWraps = NO;
    self.fontSizeStepper.doubleValue = [[NSUserDefaults standardUserDefaults] doubleForKey:TTTableFontSizeKey];
    self.fontSizeStepper.target = self;
    self.fontSizeStepper.action = @selector(fontSizeStepperChanged:);
    [contentView addSubview:self.fontSizeStepper];

    // Font size label showing current size
    self.fontSizeLabel = [NSTextField labelWithString:[NSString stringWithFormat:@"%.0f", self.fontSizeStepper.doubleValue]];
    self.fontSizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.fontSizeLabel.alignment = NSTextAlignmentRight;
    [contentView addSubview:self.fontSizeLabel];

    // Layout
    NSDictionary *views = @{
        @"fontLabel": fontLabel,
        @"fontButton": self.fontButton,
        @"sizeLabel": sizeLabel,
        @"stepper": self.fontSizeStepper,
        @"sizeValue": self.fontSizeLabel
    };

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[fontLabel]-8-[fontButton]->=8-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[sizeLabel]-8-[sizeValue(40)]-4-[stepper]->=8-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[fontLabel]-16-[sizeLabel]->=8-|" options:0 metrics:nil views:views]];
}

- (NSString *)currentFontDisplayName {
    NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:TTTableFontNameKey];
    if (fontName) {
        NSFont *font = [NSFont fontWithName:fontName size:13];
        return font ? font.displayName : fontName;
    }
    return [NSFont systemFontOfSize:13].displayName;
}

- (void)fontButtonClicked:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:TTTableFontNameKey];
    CGFloat size = [[NSUserDefaults standardUserDefaults] doubleForKey:TTTableFontSizeKey];
    NSFont *currentFont;
    if (fontName) {
        currentFont = [NSFont fontWithName:fontName size:size];
    }
    if (!currentFont) {
        currentFont = [NSFont systemFontOfSize:size];
    }
    [fontManager setSelectedFont:currentFont isMultiple:NO];
    [fontManager setTarget:self];
    [[fontManager fontPanel:YES] makeKeyAndOrderFront:sender];
}

- (void)changeFont:(id)sender {
    NSFontManager *fontManager = (NSFontManager *)sender;
    NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:TTTableFontNameKey];
    CGFloat size = [[NSUserDefaults standardUserDefaults] doubleForKey:TTTableFontSizeKey];
    NSFont *oldFont = fontName ? [NSFont fontWithName:fontName size:size] : [NSFont systemFontOfSize:size];
    if (!oldFont) oldFont = [NSFont systemFontOfSize:size];
    NSFont *newFont = [fontManager convertFont:oldFont];
    [[NSUserDefaults standardUserDefaults] setObject:newFont.fontName forKey:TTTableFontNameKey];
    [self.fontButton setTitle:newFont.displayName];
}

- (void)fontSizeStepperChanged:(NSStepper *)sender {
    NSInteger size = (NSInteger)sender.doubleValue;
    [[NSUserDefaults standardUserDefaults] setInteger:size forKey:TTTableFontSizeKey];
    self.fontSizeLabel.stringValue = [NSString stringWithFormat:@"%ld", (long)size];
}

-(IBAction)showPreferences:(id)sender {
    [self showWindow:sender];
}

@end
