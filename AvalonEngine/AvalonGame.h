//
//  AvalonGame.h
//  
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Avalon.h"

@class AvalonPlayer, AvalonQuest;

@interface AvalonGame : NSObject

+ (instancetype)gameWithVariant:(AvalonGameVariant)variant;

@property (nonatomic, strong) AvalonPlayer *currentLeader;
@property (nonatomic, strong) AvalonPlayer *assassinatedPlayer;
@property (nonatomic, readonly) AvalonQuest *currentQuest;
@property (nonatomic, readonly) NSArray *players;
@property (nonatomic, readonly) NSArray *roles;
@property (nonatomic, readonly) NSArray *quests;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
@property (nonatomic, assign) AvalonGameState state;
@property (nonatomic, assign) NSInteger voteNumber;
@property (nonatomic, assign) NSInteger questNumber;
@property (nonatomic, assign) NSUInteger passedQuestCount;
@property (nonatomic, assign) NSUInteger failedQuestCount;
@property (nonatomic, strong) AvalonPlayer *observer;
@property (nonatomic, readonly) AvalonGameVariant variant;

- (BOOL)hasPlayer:(AvalonPlayer *)player;

- (BOOL)hasPlayers:(NSArray *)players;

- (void)addPlayer:(AvalonPlayer *)player;

- (void)removePlayer:(AvalonPlayer *)player;

- (void)addQuest:(AvalonQuest *)quest;

- (AvalonPlayer *)playerWithId:(NSString *)playerId;

- (NSArray *)playersWithIds:(NSArray *)playerIds;

- (instancetype)sanitizedCopyForPlayer:(AvalonPlayer *)player;

@end

