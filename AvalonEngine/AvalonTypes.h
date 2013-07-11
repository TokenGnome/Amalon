//
//  AvalonTypes.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Availability.h>

#ifndef __AVALONTYPES__
#define __AVALONTYPES__

@protocol AvalonJSON <NSObject>
- (id)toJSON;
@end

@interface NSObject (AvalonJSON) <AvalonJSON>
@end

@interface NSArray (AvalonJSON) <AvalonJSON>
@end

@interface NSDictionary (AvalonJSON) <AvalonJSON>
@end


typedef NS_ENUM(NSUInteger, AvalonRoleType) {
    AvalonRoleNone     = 0x0,
    AvalonRoleServant  = 0x1 << 1, //2
    AvalonRoleMinion   = 0x1 << 2, //4
    AvalonRoleMerlin   = 0x1 << 3, //8
    AvalonRoleAssassin = 0x1 << 4, //16
    AvalonRolePercival = 0x1 << 5, //32
    AvalonRoleMordred  = 0x1 << 6, //64
    AvalonRoleMorgana  = 0x1 << 7, //128
    AvalonRoleOberon   = 0x1 << 8, //256
    AvalonRoleMerlinOrMorgana = AvalonRoleMerlin | AvalonRoleMorgana, //136
    AvalonRoleGood = AvalonRoleServant| AvalonRoleMerlin | AvalonRolePercival, //42
    AvalonRoleGoodOrMordred = AvalonRoleGood | AvalonRoleMordred, //106
    AvalonRoleGoodOrOberon = AvalonRoleGood | AvalonRoleOberon, //298
    AvalonRoleEvilNotMordred = AvalonRoleMinion | AvalonRoleAssassin | AvalonRoleMorgana | AvalonRoleOberon, //404
    AvalonRoleEvilNotOberon = AvalonRoleMinion | AvalonRoleAssassin | AvalonRoleMorgana | AvalonRoleMordred, //212
    AvalonRoleEvil = AvalonRoleEvilNotOberon | AvalonRoleOberon //468
};

typedef NS_ENUM(NSUInteger, AvalonGameVariant) {
    AvalonVariantDefault = AvalonRoleMinion | AvalonRoleServant | AvalonRoleMerlin | AvalonRoleAssassin,
    AvalonVariantMordred = AvalonVariantDefault | AvalonRoleMordred,
    AvalonVariantPercival = AvalonVariantDefault | AvalonRolePercival,
    AvalonVariantMorgana = AvalonVariantPercival | AvalonRoleMorgana,
    AvalonVariantNoOberon = AvalonVariantMorgana | AvalonRoleMordred,
    AvalonVariantAll = AvalonVariantNoOberon | AvalonRoleOberon
};

typedef NS_ENUM(NSUInteger, AvalonGameState) {
    GameStateNotStarted = 0,
    GameStateRolesAssigned,
    GameStateProposing,
    GameStateProposingCompleted,
    GameStateVoting,
    GameStateVotingCompleted,
    GameStateQuesting,
    GameStateQuestingCompleted,
    GameStateAssassinating,
    GameStateAssassinatingCompleted,
    GameStateEnded
};

typedef NS_ENUM(NSUInteger, AvalonPlayerCount) {
    AvalonMinPlayerCount = 5,
    AvalonMaxPlayerCount = 10
};

extern NSString *kAvalonRuleErrorDomain;
extern NSArray *GenerateRoles(AvalonGameVariant variant, NSUInteger playerCount);
extern NSString *NameForRoleType(AvalonRoleType type);
extern AvalonRoleType RoleAsSeenByRole(AvalonRoleType targetType, AvalonRoleType observerType);
extern NSUInteger TeamSizeForQuestNumber(NSUInteger questNumber, NSUInteger playerCount);
extern NSUInteger FailsRequiredForQuestNumber(NSUInteger questNumber, NSUInteger playerCount);
extern NSString *BundledScript(NSString *nameWithoutExtension);

#endif