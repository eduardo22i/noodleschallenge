/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing a player in the Four-In-A-Row game.
 */
@import Foundation;

typedef NS_ENUM(NSInteger, AAPLPlayerType) {
    AAPLPlayerTypeNone = 0,
    AAPLPlayerTypeHuman,
    AAPLPlayerTypeComputer
};

@interface AAPLPlayer : NSObject

+ (AAPLPlayer *)humanPlayer;
+ (AAPLPlayer *)aiPlayer;
+ (NSArray<AAPLPlayer *> *)allPlayers;

@property (nonatomic, readonly) AAPLPlayerType type;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) AAPLPlayer *opponent;

@end
