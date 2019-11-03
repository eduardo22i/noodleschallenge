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

@property AAPLPlayer * _Nonnull currentPlayer;

+ (NSInteger)width;
+ (NSInteger)height;

- (nonnull instancetype)initWithChips:(nonnull NSArray<NSNumber *> *) cells;
- (AAPLChip)chipsInColumn:(NSInteger)column row:(NSInteger)row;
- (BOOL)canRemoveChips:(NSInteger)count inColumn:(NSInteger)column;
- (void)removeChips:(NSInteger)count inColumn:(NSInteger)column;

- (BOOL)isFull;

- (NSArray<NSNumber *> *_Nonnull)runCountsForPlayer:(AAPLPlayer *_Nonnull)player;

- (void)updateChipsFromBoard:(AAPLBoard *_Nonnull)otherBoard;

@end
