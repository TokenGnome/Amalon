//
//  AvalonEngine.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonTypes.h"
#import "AvalonGame.h"
#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AvalonProposal.h"
#import "AvalonRole.h"

@protocol AvalonEngineDelegate;

@interface AvalonEngine : NSObject

+ (instancetype)engine;

@property (nonatomic, weak) id<AvalonEngineDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *deciders;

- (void)step:(AvalonGame *)game;

- (AvalonGame *)gameStateForPlayer:(NSString *)playerId game:(AvalonGame *)game;

- (NSString *)playerIdForRole:(AvalonRoleType)role game:(AvalonGame *)game;

- (NSError *)proposeQuest:(NSArray *)playerIds proposer:(NSString *)playerId game:(AvalonGame *)game;

- (NSError *)acceptProposal:(BOOL)vote voter:(NSString *)playerId game:(AvalonGame *)game;

- (NSError *)assassinatePlayer:(NSString *)playerId assassin:(NSString *)assassinId game:(AvalonGame *)game;

- (NSError *)passQuest:(BOOL)vote voter:(NSString *)playerId game:(AvalonGame *)game;

@end

@protocol AvalonEngineDelegate <NSObject>

- (void)gameNeedsProposal:(AvalonGame *)game;

- (void)gameNeedsVotes:(AvalonGame *)game;

- (void)gameNeedsPass:(AvalonGame *)game;

- (void)gameNeedsAssassinationTarget:(AvalonGame *)game;

@end
