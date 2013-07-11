//
//  AvalonEngine.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Avalon.h"

@class AvalonGame, AvalonPlayer, AvalonQuest, AvalonRole;

@protocol AvalonDecider;

@interface AvalonEngine : NSObject

+ (instancetype)engine;

- (void)addPlayer:(NSString *)playerId toGame:(AvalonGame *)game decider:(id<AvalonDecider>)controller;

- (void)removePlayer:(NSString *)playerId fromGame:(AvalonGame *)game;

- (void)startGame:(AvalonGame *)game withVariant:(AvalonGameVariant)variant;

- (void)step:(AvalonGame *)game;

@end

@protocol AvalonDecider <NSObject>

- (NSArray *)questProposalForGameState:(AvalonGame *)state;

- (BOOL)acceptProposalForGameState:(AvalonGame *)state;

- (BOOL)passQuestForGameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end