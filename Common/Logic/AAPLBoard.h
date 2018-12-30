/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing the Four-In-A-Row game board.
 */

@import Foundation;

#import "AAPLPlayer.h"

const static NSInteger AAPLCountToWin = 1;

@interface AAPLBoard : NSObject

@property AAPLPlayer *currentPlayer;

+ (NSInteger)width;
+ (NSInteger)height;

- (nonnull instancetype)initWithChips:(nonnull NSArray<NSNumber *> *) cells;
- (AAPLPlayerType)chipsInColumn:(NSInteger)column row:(NSInteger)row;
- (BOOL)canRemoveChips:(NSInteger)count inColumn:(NSInteger)column;
- (void)removeChips:(NSInteger)count inColumn:(NSInteger)column;

- (void)updateChipsFromBoard:(AAPLBoard *)otherBoard;

@end
