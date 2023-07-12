/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing a player in the Four-In-A-Row game.
 */
@import Foundation;

typedef NS_ENUM(NSInteger, AAPLType) {
    AAPLTypeNone = 0,
    AAPLTypeHuman,
    AAPLTypeComputer
};

@interface AAPLPlayer : NSObject

+ (AAPLPlayer *)humanPlayer;
+ (AAPLPlayer *)computerPlayer;
+ (NSArray<AAPLPlayer *> *)allPlayers;
+ (AAPLPlayer *)playerForType:(AAPLType)type;

@property (nonatomic, readonly) AAPLType type;
@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, readonly) AAPLPlayer *opponent;

@end
