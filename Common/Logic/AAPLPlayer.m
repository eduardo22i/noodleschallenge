/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing a player in the Four-In-A-Row game.
 */

#import "AAPLPlayer.h"

@interface AAPLPlayer ()
@property (readwrite) AAPLPlayerType chip;
@property (nonatomic, readwrite, copy) NSString *name;
@end

@implementation AAPLPlayer

- (instancetype)initWithChip:(AAPLPlayerType)chip {
    self = [super init];

    if (self) {
        _chip = chip;
    }
    
    return self;
}

+ (AAPLPlayer *)humanPlayer {
    return [self allPlayers][AAPLPlayerTypeHuman];
}

+ (AAPLPlayer *)aiPlayer {
    return [self allPlayers][AAPLPlayerTypeComputer];
}

+ (NSArray<AAPLPlayer *> *)allPlayers {
    static NSArray<AAPLPlayer *> *allPlayers = nil;

    if (allPlayers == nil) {
        allPlayers = @[
           [[AAPLPlayer alloc] initWithChip:AAPLPlayerTypeHuman],
           [[AAPLPlayer alloc] initWithChip:AAPLPlayerTypeComputer],
        ];
    }

    return allPlayers;
}

- (NSString *)name {
    switch (self.chip) {
        case AAPLPlayerTypeHuman:
            return @"Human";

        case AAPLPlayerTypeComputer:
            return @"AI";
        
        default:
            return nil;
    }
}

- (NSString *)debugDescription {
    switch (self.chip) {
        case AAPLPlayerTypeHuman:
            return @"X";

        case AAPLPlayerTypeComputer:
            return @"O";
        
        default:
            return @" ";
    }
}

- (AAPLPlayer *)opponent {
    switch (self.chip) {
        case AAPLPlayerTypeHuman:
            return [AAPLPlayer aiPlayer];

        case AAPLPlayerTypeComputer:
            return [AAPLPlayer humanPlayer];
        
        default:
            return nil;
    }
}

@end
