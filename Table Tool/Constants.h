//
//  Constants.h
//  Table Tool
//
//  Created by Martin Koehler on 12.06.17.
//  Copyright (c) 2017 Egger Apps. All rights reserved.
//

#include <Cocoa/Cocoa.h>

#pragma mark Pasteboard Types

extern NSPasteboardType TTRowInternalPboardType;

#pragma mark Table Column Identifiers

extern NSString *TTLineNumberColumnIdentifier;

#pragma mark User Defaults Keys

extern NSString *TTShowLineNumbersKey;
extern NSString *TTTableFontNameKey;
extern NSString *TTTableFontSizeKey;
extern NSString *TTAlternatingRowColorsKey;
extern NSString *TTRowHeightKey;
extern NSString *TTDefaultEncodingKey;
extern NSString *TTDefaultColumnSeparatorKey;
extern NSString *TTDefaultFirstRowAsHeaderKey;

#pragma mark Table View

extern const CGFloat TTMinRowHeight;
extern const CGFloat TTMaxRowHeight;
