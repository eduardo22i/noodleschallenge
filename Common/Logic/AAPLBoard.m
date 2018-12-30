/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing the Four-In-A-Row game board.
 */

#import "AAPLBoard.h"

const static NSInteger AAPLBoardWidth = 3;
const static NSInteger AAPLBoardHeight = 1;

@implementation AAPLBoard {
    NSInteger _cells[AAPLBoardWidth * AAPLBoardHeight];
}

+ (NSInteger)width {
	return AAPLBoardWidth;
}

+ (NSInteger)height {
	return AAPLBoardHeight;
}

- (instancetype)initWithChips:(NSArray<NSNumber *> *) cells {
	self = [super init];

    for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
        _cells[column] = [[cells objectAtIndex:column] integerValue];
    }
    
    if (self) {
		_currentPlayer = [AAPLPlayer humanPlayer];
	}
	
    return self;
}

- (void)updateChipsFromBoard:(AAPLBoard *)otherBoard {
	memcpy(_cells, otherBoard->_cells, sizeof(_cells));
}

- (AAPLPlayerType)chipsInColumn:(NSInteger)column row:(NSInteger)row {
    return _cells[row + column];
}

- (void)removeChips:(NSInteger)count inColumn:(NSInteger)column {
    _cells[column] -= count;
}

- (NSString *)debugDescription {
    NSMutableString *output = [NSMutableString string];

    for (NSInteger row = AAPLBoardHeight - 1; row >= 0; row--) {
        for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
            NSInteger chip = [self chipsInColumn:column row:row];
            
            NSString *playerDescription = [NSString stringWithFormat:@"%ld", (long)chip];
            [output appendString:playerDescription];
            
			NSString *cellDescription = (column + 1 < AAPLBoardWidth) ? @"." : @"";
            [output appendString:cellDescription];
        }
    
        [output appendString:((row > 0) ? @"\n" : @"")];
    }

    return output;
}

- (BOOL)canRemoveChips:(NSInteger)count inColumn:(NSInteger)column {
    return _cells[column] >= count;
}

@end
