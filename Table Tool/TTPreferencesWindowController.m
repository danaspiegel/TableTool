//
//  TTPreferencesWindowController.m
//  Table Tool
//
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "TTPreferencesWindowController.h"
#import "Constants.h"
#import "CSVConfiguration.h"

@interface TTPreferencesWindowController ()
// Appearance tab
@property (nonatomic, strong) NSButton *fontButton;
@property (nonatomic, strong) NSStepper *fontSizeStepper;
@property (nonatomic, strong) NSTextField *fontSizeField;

// General tab
@property (nonatomic, strong) NSButton *showLineNumbersCheckbox;
@property (nonatomic, strong) NSButton *alternatingRowColorsCheckbox;
@property (nonatomic, strong) NSStepper *rowHeightStepper;
@property (nonatomic, strong) NSTextField *rowHeightField;

// CSV Defaults tab
@property (nonatomic, strong) NSPopUpButton *encodingPopup;
@property (nonatomic, strong) NSPopUpButton *separatorPopup;
@property (nonatomic, strong) NSButton *firstRowAsHeaderCheckbox;
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
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 440, 300)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    window.title = @"Preferences";
    [window center];
    self = [super initWithWindow:window];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    NSView *contentView = self.window.contentView;

    NSTabView *tabView = [[NSTabView alloc] init];
    tabView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:tabView];

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tabView]-0-|"
                                                                        options:0 metrics:nil
                                                                          views:@{@"tabView": tabView}]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tabView]-0-|"
                                                                        options:0 metrics:nil
                                                                          views:@{@"tabView": tabView}]];

    NSTabViewItem *generalTab = [[NSTabViewItem alloc] initWithIdentifier:@"general"];
    generalTab.label = @"General";
    generalTab.view = [self buildGeneralTabView];
    [tabView addTabViewItem:generalTab];

    NSTabViewItem *appearanceTab = [[NSTabViewItem alloc] initWithIdentifier:@"appearance"];
    appearanceTab.label = @"Appearance";
    appearanceTab.view = [self buildAppearanceTabView];
    [tabView addTabViewItem:appearanceTab];

    NSTabViewItem *csvTab = [[NSTabViewItem alloc] initWithIdentifier:@"csv"];
    csvTab.label = @"CSV Defaults";
    csvTab.view = [self buildCSVDefaultsTabView];
    [tabView addTabViewItem:csvTab];
}

#pragma mark - General Tab

- (NSView *)buildGeneralTabView {
    NSView *view = [[NSView alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Show line numbers checkbox
    self.showLineNumbersCheckbox = [NSButton checkboxWithTitle:@"Show line numbers"
                                                        target:self
                                                        action:@selector(showLineNumbersChanged:)];
    self.showLineNumbersCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    self.showLineNumbersCheckbox.state = [defaults boolForKey:TTShowLineNumbersKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [view addSubview:self.showLineNumbersCheckbox];

    // Alternating row colors checkbox
    self.alternatingRowColorsCheckbox = [NSButton checkboxWithTitle:@"Use alternating row colors"
                                                             target:self
                                                             action:@selector(alternatingRowColorsChanged:)];
    self.alternatingRowColorsCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    self.alternatingRowColorsCheckbox.state = [defaults boolForKey:TTAlternatingRowColorsKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [view addSubview:self.alternatingRowColorsCheckbox];

    // Row height label
    NSTextField *rowHeightLabel = [NSTextField labelWithString:@"Row height:"];
    rowHeightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:rowHeightLabel];

    // Row height text field
    self.rowHeightField = [[NSTextField alloc] init];
    self.rowHeightField.translatesAutoresizingMaskIntoConstraints = NO;
    self.rowHeightField.doubleValue = [defaults doubleForKey:TTRowHeightKey];
    self.rowHeightField.formatter = [self integerNumberFormatter];
    self.rowHeightField.target = self;
    self.rowHeightField.action = @selector(rowHeightFieldChanged:);
    [view addSubview:self.rowHeightField];

    // Row height stepper
    self.rowHeightStepper = [[NSStepper alloc] init];
    self.rowHeightStepper.translatesAutoresizingMaskIntoConstraints = NO;
    self.rowHeightStepper.minValue = TTMinRowHeight;
    self.rowHeightStepper.maxValue = TTMaxRowHeight;
    self.rowHeightStepper.increment = 1;
    self.rowHeightStepper.valueWraps = NO;
    self.rowHeightStepper.doubleValue = [defaults doubleForKey:TTRowHeightKey];
    self.rowHeightStepper.target = self;
    self.rowHeightStepper.action = @selector(rowHeightStepperChanged:);
    [view addSubview:self.rowHeightStepper];

    // Row height points label
    NSTextField *ptsLabel = [NSTextField labelWithString:@"points"];
    ptsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:ptsLabel];

    NSDictionary *views = @{
        @"lineNumbers": self.showLineNumbersCheckbox,
        @"alternating": self.alternatingRowColorsCheckbox,
        @"rowHeightLabel": rowHeightLabel,
        @"rowHeightField": self.rowHeightField,
        @"rowHeightStepper": self.rowHeightStepper,
        @"ptsLabel": ptsLabel
    };

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[lineNumbers]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[alternating]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[rowHeightLabel]-8-[rowHeightField(48)]-2-[rowHeightStepper]-8-[ptsLabel]->=20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[lineNumbers]-12-[alternating]-12-[rowHeightLabel]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    return view;
}

#pragma mark - Appearance Tab

- (NSView *)buildAppearanceTabView {
    NSView *view = [[NSView alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Font label
    NSTextField *fontLabel = [NSTextField labelWithString:@"Table font:"];
    fontLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:fontLabel];

    // Font button
    self.fontButton = [NSButton buttonWithTitle:[self currentFontDisplayName]
                                         target:self
                                         action:@selector(fontButtonClicked:)];
    self.fontButton.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.fontButton];

    // Size label
    NSTextField *sizeLabel = [NSTextField labelWithString:@"Size:"];
    sizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:sizeLabel];

    // Font size text field
    self.fontSizeField = [[NSTextField alloc] init];
    self.fontSizeField.translatesAutoresizingMaskIntoConstraints = NO;
    self.fontSizeField.doubleValue = [defaults doubleForKey:TTTableFontSizeKey];
    self.fontSizeField.formatter = [self integerNumberFormatter];
    self.fontSizeField.target = self;
    self.fontSizeField.action = @selector(fontSizeFieldChanged:);
    [view addSubview:self.fontSizeField];

    // Font size stepper
    self.fontSizeStepper = [[NSStepper alloc] init];
    self.fontSizeStepper.translatesAutoresizingMaskIntoConstraints = NO;
    self.fontSizeStepper.minValue = 6;
    self.fontSizeStepper.maxValue = 72;
    self.fontSizeStepper.increment = 1;
    self.fontSizeStepper.valueWraps = NO;
    self.fontSizeStepper.doubleValue = [defaults doubleForKey:TTTableFontSizeKey];
    self.fontSizeStepper.target = self;
    self.fontSizeStepper.action = @selector(fontSizeStepperChanged:);
    [view addSubview:self.fontSizeStepper];

    // Points label
    NSTextField *ptLabel = [NSTextField labelWithString:@"points"];
    ptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:ptLabel];

    NSDictionary *views = @{
        @"fontLabel": fontLabel,
        @"fontButton": self.fontButton,
        @"sizeLabel": sizeLabel,
        @"sizeField": self.fontSizeField,
        @"stepper": self.fontSizeStepper,
        @"ptLabel": ptLabel
    };

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[fontLabel]-8-[fontButton]->=20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[sizeLabel]-8-[sizeField(48)]-2-[stepper]-8-[ptLabel]->=20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[fontLabel]-16-[sizeLabel]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    return view;
}

#pragma mark - CSV Defaults Tab

- (NSView *)buildCSVDefaultsTabView {
    NSView *view = [[NSView alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Encoding label
    NSTextField *encodingLabel = [NSTextField labelWithString:@"Default encoding:"];
    encodingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:encodingLabel];

    // Encoding popup
    self.encodingPopup = [[NSPopUpButton alloc] init];
    self.encodingPopup.translatesAutoresizingMaskIntoConstraints = NO;
    NSInteger savedEncoding = [defaults integerForKey:TTDefaultEncodingKey];
    for (NSArray *encoding in [CSVConfiguration supportedEncodings]) {
        [self.encodingPopup addItemWithTitle:encoding[0]];
        self.encodingPopup.lastItem.tag = [encoding[1] integerValue];
        if ([encoding[1] integerValue] == savedEncoding) {
            [self.encodingPopup selectItem:self.encodingPopup.lastItem];
        }
    }
    self.encodingPopup.target = self;
    self.encodingPopup.action = @selector(encodingChanged:);
    [view addSubview:self.encodingPopup];

    // Separator label
    NSTextField *separatorLabel = [NSTextField labelWithString:@"Default separator:"];
    separatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:separatorLabel];

    // Separator popup
    self.separatorPopup = [[NSPopUpButton alloc] init];
    self.separatorPopup.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *savedSeparator = [defaults stringForKey:TTDefaultColumnSeparatorKey] ?: @",";
    NSDictionary *separators = [self separatorNameToValueMap];
    NSArray *separatorOrder = [self separatorDisplayOrder];
    for (NSString *name in separatorOrder) {
        [self.separatorPopup addItemWithTitle:name];
        if ([separators[name] isEqualToString:savedSeparator]) {
            [self.separatorPopup selectItem:self.separatorPopup.lastItem];
        }
    }
    self.separatorPopup.target = self;
    self.separatorPopup.action = @selector(separatorChanged:);
    [view addSubview:self.separatorPopup];

    // First row as header checkbox
    self.firstRowAsHeaderCheckbox = [NSButton checkboxWithTitle:@"Use first row as header by default"
                                                         target:self
                                                         action:@selector(firstRowAsHeaderChanged:)];
    self.firstRowAsHeaderCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    self.firstRowAsHeaderCheckbox.state = [defaults boolForKey:TTDefaultFirstRowAsHeaderKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [view addSubview:self.firstRowAsHeaderCheckbox];

    NSDictionary *views = @{
        @"encodingLabel": encodingLabel,
        @"encodingPopup": self.encodingPopup,
        @"separatorLabel": separatorLabel,
        @"separatorPopup": self.separatorPopup,
        @"firstRowAsHeader": self.firstRowAsHeaderCheckbox
    };

    CGFloat labelWidth = 130;
    [view addConstraint:[NSLayoutConstraint constraintWithItem:encodingLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:labelWidth]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:separatorLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:labelWidth]];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[encodingLabel]-8-[encodingPopup]->=20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[separatorLabel]-8-[separatorPopup]->=20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[firstRowAsHeader]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[encodingLabel]-12-[separatorLabel]-12-[firstRowAsHeader]->=20-|"
                                                                 options:0 metrics:nil views:views]];
    return view;
}

#pragma mark - Helpers

- (NSDictionary *)separatorNameToValueMap {
    return @{@"Comma  ( , )": @",", @"Semicolon  ( ; )": @";", @"Tab  ( ⇥ )": @"\t", @"Pipe  ( | )": @"|"};
}

- (NSArray *)separatorDisplayOrder {
    return @[@"Comma  ( , )", @"Semicolon  ( ; )", @"Tab  ( ⇥ )", @"Pipe  ( | )"];
}

- (NSNumberFormatter *)integerNumberFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 0;
    return formatter;
}

- (NSString *)currentFontDisplayName {
    NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:TTTableFontNameKey];
    if (fontName) {
        NSFont *font = [NSFont fontWithName:fontName size:13];
        return font ? font.displayName : fontName;
    }
    return [NSFont systemFontOfSize:13].displayName;
}

#pragma mark - General Tab Actions

- (void)showLineNumbersChanged:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(sender.state == NSControlStateValueOn) forKey:TTShowLineNumbersKey];
}

- (void)alternatingRowColorsChanged:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(sender.state == NSControlStateValueOn) forKey:TTAlternatingRowColorsKey];
}

- (void)rowHeightFieldChanged:(NSTextField *)sender {
    double value = MAX(TTMinRowHeight, MIN(TTMaxRowHeight, sender.doubleValue));
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:TTRowHeightKey];
    self.rowHeightStepper.doubleValue = value;
}

- (void)rowHeightStepperChanged:(NSStepper *)sender {
    double value = sender.doubleValue;
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:TTRowHeightKey];
    self.rowHeightField.doubleValue = value;
}

#pragma mark - Appearance Tab Actions

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
    NSInteger newSize = (NSInteger)newFont.pointSize;
    [[NSUserDefaults standardUserDefaults] setInteger:newSize forKey:TTTableFontSizeKey];
    [self.fontButton setTitle:newFont.displayName];
    self.fontSizeField.integerValue = newSize;
    self.fontSizeStepper.integerValue = newSize;
}

- (void)fontSizeFieldChanged:(NSTextField *)sender {
    NSInteger size = MAX(6, MIN(72, sender.integerValue));
    [[NSUserDefaults standardUserDefaults] setInteger:size forKey:TTTableFontSizeKey];
    self.fontSizeStepper.integerValue = size;
}

- (void)fontSizeStepperChanged:(NSStepper *)sender {
    NSInteger size = (NSInteger)sender.doubleValue;
    [[NSUserDefaults standardUserDefaults] setInteger:size forKey:TTTableFontSizeKey];
    self.fontSizeField.integerValue = size;
}

#pragma mark - CSV Defaults Tab Actions

- (void)encodingChanged:(NSPopUpButton *)sender {
    NSInteger encoding = sender.selectedItem.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:encoding forKey:TTDefaultEncodingKey];
}

- (void)separatorChanged:(NSPopUpButton *)sender {
    NSDictionary *separators = [self separatorNameToValueMap];
    NSString *separator = separators[sender.selectedItem.title] ?: @",";
    [[NSUserDefaults standardUserDefaults] setObject:separator forKey:TTDefaultColumnSeparatorKey];
}

- (void)firstRowAsHeaderChanged:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:(sender.state == NSControlStateValueOn) forKey:TTDefaultFirstRowAsHeaderKey];
}

-(IBAction)showPreferences:(id)sender {
    [self showWindow:sender];
}

@end
