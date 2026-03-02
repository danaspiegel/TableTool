//
//  TTPreferencesWindowController.m
//  Table Tool
//
//  Copyright (c) 2015 Egger Apps. All rights reserved.
//

#import "TTPreferencesWindowController.h"
#import "Constants.h"
#import "CSVConfiguration.h"

// Layout constants matching macOS HIG spacing guidelines
static const CGFloat kEdgeInset        = 20.0;  // margin around each pane
static const CGFloat kLabelColumnWidth = 140.0; // fixed width for right-aligned label column
static const CGFloat kColumnGap        =   8.0; // gap between label and control columns
static const CGFloat kRowSpacing       =   8.0; // vertical spacing between form rows
static const CGFloat kGroupSpacing     =   8.0; // extra spacer row height between groups
static const CGFloat kNumericFieldWidth=  44.0; // width of numeric text fields

@interface TTPreferencesWindowController ()
// General pane
@property (nonatomic, strong) NSButton    *showLineNumbersCheckbox;
@property (nonatomic, strong) NSButton    *alternatingRowColorsCheckbox;
@property (nonatomic, strong) NSStepper   *rowHeightStepper;
@property (nonatomic, strong) NSTextField *rowHeightField;
// Appearance pane
@property (nonatomic, strong) NSButton    *fontButton;
@property (nonatomic, strong) NSStepper   *fontSizeStepper;
@property (nonatomic, strong) NSTextField *fontSizeField;
// CSV Defaults pane
@property (nonatomic, strong) NSPopUpButton *encodingPopup;
@property (nonatomic, strong) NSPopUpButton *separatorPopup;
@property (nonatomic, strong) NSButton      *firstRowAsHeaderCheckbox;
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
    // Initial content rect; NSTabViewController resizes the window per pane.
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 480, 200)
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    window.title = @"Settings";
    self = [super initWithWindow:window];
    if (self) {
        [self buildUI];
        [window center];
    }
    return self;
}

// ---------------------------------------------------------------------------
#pragma mark - Window / Tab construction
// ---------------------------------------------------------------------------

- (void)buildUI {
    // Modern macOS preferences style: toolbar across the top, one pane per icon.
    // This matches the Safari / Mail "Settings" window pattern on macOS 13+.
    NSTabViewController *tabVC = [[NSTabViewController alloc] init];
    tabVC.tabStyle = NSTabViewControllerStyleToolbar;

    [tabVC addTabViewItem:[self tabItemIdentifier:@"general"
                                           label:@"General"
                                      symbolName:@"gearshape"
                                    fallbackName:NSImageNamePreferencesGeneral
                                            pane:[self buildGeneralPane]
                                     contentSize:NSMakeSize(480, 152)]];

    [tabVC addTabViewItem:[self tabItemIdentifier:@"appearance"
                                           label:@"Appearance"
                                      symbolName:@"paintbrush"
                                    fallbackName:NSImageNameColorPanel
                                            pane:[self buildAppearancePane]
                                     contentSize:NSMakeSize(480, 112)]];

    [tabVC addTabViewItem:[self tabItemIdentifier:@"csv"
                                           label:@"CSV Defaults"
                                      symbolName:@"doc.text"
                                    fallbackName:NSImageNameShareTemplate
                                            pane:[self buildCSVDefaultsPane]
                                     contentSize:NSMakeSize(480, 168)]];

    self.window.contentViewController = tabVC;
}

/// Builds one NSTabViewItem wired to a plain NSViewController whose view is
/// already fully laid out.  preferredContentSize drives the window resize
/// animation when the user switches tabs.
- (NSTabViewItem *)tabItemIdentifier:(NSString *)identifier
                               label:(NSString *)label
                          symbolName:(NSString *)symbolName
                        fallbackName:(NSString *)fallbackName
                                pane:(NSView *)pane
                         contentSize:(NSSize)size {
    NSViewController *vc = [[NSViewController alloc] init];
    vc.view = pane;
    vc.preferredContentSize = size;

    NSImage *icon;
    if (@available(macOS 11.0, *)) {
        icon = [NSImage imageWithSystemSymbolName:symbolName
                         accessibilityDescription:label];
    } else {
        icon = [NSImage imageNamed:fallbackName];
    }

    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:identifier];
    item.label = label;
    item.image = icon;
    item.viewController = vc;
    return item;
}

// ---------------------------------------------------------------------------
#pragma mark - Form-layout helpers
// ---------------------------------------------------------------------------

/// Returns a two-column NSGridView configured for a standard macOS form:
///   column 0 — right-aligned labels, fixed kLabelColumnWidth wide
///   column 1 — controls, left-aligned
- (NSGridView *)newFormGrid {
    NSGridView *grid = [NSGridView gridViewWithNumberOfColumns:2 rows:0];
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    grid.columnSpacing = kColumnGap;
    grid.rowSpacing    = kRowSpacing;

    NSGridColumn *labelCol = [grid columnAtIndex:0];
    labelCol.xPlacement = NSGridCellPlacementTrailing; // right-align within column
    labelCol.width      = kLabelColumnWidth;
    return grid;
}

/// Creates a non-editable right-aligned label suitable for the label column.
- (NSTextField *)formLabel:(NSString *)title {
    NSTextField *label = [NSTextField labelWithString:title];
    label.alignment = NSTextAlignmentRight;
    return label;
}

/// Creates a right-aligned editable numeric text field with a fixed width.
- (NSTextField *)numericFieldWithValue:(double)value {
    NSTextField *field = [[NSTextField alloc] init];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.alignment          = NSTextAlignmentRight;
    field.usesSingleLineMode = YES;
    field.doubleValue        = value;
    field.formatter          = [self integerNumberFormatter];
    [field.widthAnchor constraintEqualToConstant:kNumericFieldWidth].active = YES;
    return field;
}

/// Returns an NSStackView grouping a numeric field, its stepper, and a unit
/// label — the standard macOS stepper-with-field idiom.
- (NSStackView *)stepperRowWithField:(NSTextField *)field
                             stepper:(NSStepper *)stepper
                                unit:(NSString *)unitString {
    stepper.translatesAutoresizingMaskIntoConstraints = NO;
    NSTextField *unitLabel = [NSTextField labelWithString:unitString];
    NSStackView *stack = [NSStackView stackViewWithViews:@[field, stepper, unitLabel]];
    stack.spacing     = 4;
    stack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stack.alignment   = NSLayoutAttributeCenterY;
    return stack;
}

/// Wraps an NSGridView in a container view padded by kEdgeInset on all sides.
/// Both bottom and trailing use ≥ so the container can be sized freely by
/// NSTabViewController while the grid stays anchored at the top-left.
- (NSView *)containerForGrid:(NSGridView *)grid {
    NSView *container = [[NSView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor     constraintEqualToAnchor:container.topAnchor     constant: kEdgeInset],
        [grid.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant: kEdgeInset],
        [container.trailingAnchor constraintGreaterThanOrEqualToAnchor:grid.trailingAnchor  constant:kEdgeInset],
        [container.bottomAnchor   constraintGreaterThanOrEqualToAnchor:grid.bottomAnchor    constant:kEdgeInset],
    ]];
    return container;
}

// ---------------------------------------------------------------------------
#pragma mark - Pane builders
// ---------------------------------------------------------------------------

- (NSView *)buildGeneralPane {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSGridView *grid = [self newFormGrid];

    // Row 1: "Show row numbers" checkbox — no label in column 0 (checkbox is self-labelling)
    self.showLineNumbersCheckbox =
        [NSButton checkboxWithTitle:@"Show line numbers"
                             target:self
                             action:@selector(showLineNumbersChanged:)];
    self.showLineNumbersCheckbox.state =
        [defaults boolForKey:TTShowLineNumbersKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [grid addRowWithViews:@[NSGridCell.emptyContentView, self.showLineNumbersCheckbox]];

    // Row 2: "Alternate row colors" checkbox
    self.alternatingRowColorsCheckbox =
        [NSButton checkboxWithTitle:@"Use alternating row colors"
                             target:self
                             action:@selector(alternatingRowColorsChanged:)];
    self.alternatingRowColorsCheckbox.state =
        [defaults boolForKey:TTAlternatingRowColorsKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [grid addRowWithViews:@[NSGridCell.emptyContentView, self.alternatingRowColorsCheckbox]];

    // Thin spacer between the checkbox group and the numeric row
    [grid addRowWithViews:@[NSGridCell.emptyContentView, NSGridCell.emptyContentView]];
    [grid rowAtIndex:2].height = kGroupSpacing;

    // Row 3: "Row height:" label + field + stepper + "points"
    self.rowHeightField = [self numericFieldWithValue:[defaults doubleForKey:TTRowHeightKey]];
    self.rowHeightField.target = self;
    self.rowHeightField.action = @selector(rowHeightFieldChanged:);

    self.rowHeightStepper = [[NSStepper alloc] init];
    self.rowHeightStepper.minValue    = TTMinRowHeight;
    self.rowHeightStepper.maxValue    = TTMaxRowHeight;
    self.rowHeightStepper.increment   = 1;
    self.rowHeightStepper.valueWraps  = NO;
    self.rowHeightStepper.doubleValue = [defaults doubleForKey:TTRowHeightKey];
    self.rowHeightStepper.target = self;
    self.rowHeightStepper.action = @selector(rowHeightStepperChanged:);

    NSStackView *rowHeightCtrl = [self stepperRowWithField:self.rowHeightField
                                                   stepper:self.rowHeightStepper
                                                      unit:@"points"];
    [grid addRowWithViews:@[[self formLabel:@"Row height:"], rowHeightCtrl]];

    return [self containerForGrid:grid];
}

- (NSView *)buildAppearancePane {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSGridView *grid = [self newFormGrid];

    // Row 1: "Font:" label + select button (opens Font Panel)
    self.fontButton = [NSButton buttonWithTitle:[self currentFontDisplayName]
                                         target:self
                                         action:@selector(fontButtonClicked:)];
    [grid addRowWithViews:@[[self formLabel:@"Font:"], self.fontButton]];

    // Row 2: "Size:" label + field + stepper + "points"
    self.fontSizeField = [self numericFieldWithValue:[defaults doubleForKey:TTTableFontSizeKey]];
    self.fontSizeField.target = self;
    self.fontSizeField.action = @selector(fontSizeFieldChanged:);

    self.fontSizeStepper = [[NSStepper alloc] init];
    self.fontSizeStepper.minValue    = 6;
    self.fontSizeStepper.maxValue    = 72;
    self.fontSizeStepper.increment   = 1;
    self.fontSizeStepper.valueWraps  = NO;
    self.fontSizeStepper.doubleValue = [defaults doubleForKey:TTTableFontSizeKey];
    self.fontSizeStepper.target = self;
    self.fontSizeStepper.action = @selector(fontSizeStepperChanged:);

    NSStackView *sizeCtrl = [self stepperRowWithField:self.fontSizeField
                                              stepper:self.fontSizeStepper
                                                 unit:@"points"];
    [grid addRowWithViews:@[[self formLabel:@"Size:"], sizeCtrl]];

    return [self containerForGrid:grid];
}

- (NSView *)buildCSVDefaultsPane {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSGridView *grid = [self newFormGrid];

    // Row 1: "Encoding:" popup
    self.encodingPopup = [[NSPopUpButton alloc] init];
    self.encodingPopup.translatesAutoresizingMaskIntoConstraints = NO;
    [self.encodingPopup.widthAnchor constraintGreaterThanOrEqualToConstant:220].active = YES;
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
    [grid addRowWithViews:@[[self formLabel:@"Encoding:"], self.encodingPopup]];

    // Row 2: "Separator:" popup
    self.separatorPopup = [[NSPopUpButton alloc] init];
    self.separatorPopup.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *savedSep = [defaults stringForKey:TTDefaultColumnSeparatorKey] ?: @",";
    NSDictionary *sepMap = [self separatorNameToValueMap];
    for (NSString *name in [self separatorDisplayOrder]) {
        [self.separatorPopup addItemWithTitle:name];
        if ([sepMap[name] isEqualToString:savedSep]) {
            [self.separatorPopup selectItem:self.separatorPopup.lastItem];
        }
    }
    self.separatorPopup.target = self;
    self.separatorPopup.action = @selector(separatorChanged:);
    [grid addRowWithViews:@[[self formLabel:@"Separator:"], self.separatorPopup]];

    // Thin spacer before the checkbox
    [grid addRowWithViews:@[NSGridCell.emptyContentView, NSGridCell.emptyContentView]];
    [grid rowAtIndex:2].height = kGroupSpacing;

    // Row 3: "Use first row as column headers" checkbox
    self.firstRowAsHeaderCheckbox =
        [NSButton checkboxWithTitle:@"Use first row as header by default"
                             target:self
                             action:@selector(firstRowAsHeaderChanged:)];
    self.firstRowAsHeaderCheckbox.state =
        [defaults boolForKey:TTDefaultFirstRowAsHeaderKey] ? NSControlStateValueOn : NSControlStateValueOff;
    [grid addRowWithViews:@[NSGridCell.emptyContentView, self.firstRowAsHeaderCheckbox]];

    return [self containerForGrid:grid];
}

// ---------------------------------------------------------------------------
#pragma mark - Helpers
// ---------------------------------------------------------------------------

- (NSDictionary *)separatorNameToValueMap {
    return @{@"Comma  ( , )": @",", @"Semicolon  ( ; )": @";", @"Tab  ( ⇥ )": @"\t", @"Pipe  ( | )": @"|"};
}

- (NSArray *)separatorDisplayOrder {
    return @[@"Comma  ( , )", @"Semicolon  ( ; )", @"Tab  ( ⇥ )", @"Pipe  ( | )"];
}

- (NSNumberFormatter *)integerNumberFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle         = NSNumberFormatterDecimalStyle;
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
