//
//  AvalonGame.h
//  
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonJSExports.h"
#import "Avalon.h"

@class AvalonPlayer, AvalonQuest;

@interface AvalonGame : NSObject <AvalonGameExport>

// This is a state object, but it is still kinda lazy to expose everything...
@property (nonatomic, strong) AvalonPlayer *currentLeader;
@property (nonatomic, strong) AvalonPlayer *assassinatedPlayer;
@property (nonatomic, strong) AvalonQuest *currentQuest;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSMutableArray *quests;
@property (nonatomic, strong) NSMutableArray *roles;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
@property (nonatomic, assign) AvalonGameState state;
@property (nonatomic, assign) NSInteger voteNumber;
@property (nonatomic, assign) NSInteger questNumber;
@property (nonatomic, assign) NSUInteger passedQuestCount;
@property (nonatomic, assign) NSUInteger failedQuestCount;
@property (nonatomic, strong) AvalonPlayer *observer;

- (BOOL)hasPlayer:(AvalonPlayer *)player;

- (BOOL)hasPlayers:(NSArray *)players;

- (AvalonPlayer *)playerWithId:(NSString *)playerId;

- (NSArray *)playersWithIds:(NSArray *)playerIds;

- (instancetype)sanitizedCopyForPlayer:(AvalonPlayer *)player;

@end

