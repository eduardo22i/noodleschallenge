/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing a player in the Four-In-A-Row game.
 */

#import "AAPLPlayer.h"

@interface AAPLPlayer ()
@property (readwrite) AAPLType type;
@property (nonatomic, readwrite, copy) NSString *name;
@end

@implementation AAPLPlayer

- (instancetype)initWithChip:(AAPLType)chip {
    self = [super init];

    if (self) {
        _type = chip;
    }
    
    return self;
}

+ (AAPLPlayer *)humanPlayer {
    return [self playerForType:AAPLTypeHuman];
}

+ (AAPLPlayer *)computerPlayer {
    return [self playerForType:AAPLTypeComputer];
}

+ (AAPLPlayer *)playerForType:(AAPLType)type {
	if (type == AAPLTypeNone) {
		return nil;
	}
    
    // Chip enum is 0/1/2, array is 0/1.
    return [self allPlayers][type - 1];
}

+ (NSArray<AAPLPlayer *> *)allPlayers {
    static NSArray<AAPLPlayer *> *allPlayers = nil;

    if (allPlayers == nil) {
        allPlayers = @[
           [[AAPLPlayer alloc] initWithChip:AAPLTypeHuman],
           [[AAPLPlayer alloc] initWithChip:AAPLTypeComputer],
        ];
    }

    return allPlayers;
}

- (NSString *)name {
    switch (self.type) {
        case AAPLTypeHuman:
            return @"Red";

        case AAPLTypeComputer:
            return @"COMPUTER";
        
        default:
            return nil;
    }
}

- (NSString *)debugDescription {
    switch (self.type) {
        case AAPLTypeHuman:
            return @"X";

        case AAPLTypeComputer:
            return @"O";
        
        default:
            return @" ";
    }
}

- (AAPLPlayer *)opponent {
    switch (self.type) {
        case AAPLTypeHuman:
            return [AAPLPlayer computerPlayer];

        case AAPLTypeComputer:
            return [AAPLPlayer humanPlayer];
        
        default:
            return nil;
    }
}

@end
