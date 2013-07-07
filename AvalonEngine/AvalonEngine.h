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

+ (AvalonGame *)newGame;

- (void)addPlayer:(NSString *)playerId toGame:(AvalonGame *)game decider:(id<AvalonDecider>)controller;

- (void)removePlayer:(NSString *)playerId fromGame:(AvalonGame *)game;

- (void)startGame:(AvalonGame *)game withVariant:(AvalonGameVariant)variant;

- (void)step:(AvalonGame *)game;

@end

@protocol AvalonDecider <NSObject>

@property (nonatomic, strong) AvalonRole *role;

@property (nonatomic, copy) NSString *playerId;

- (NSArray *)questProposalOfSize:(NSUInteger)size gameState:(AvalonGame *)state;

- (BOOL)acceptProposal:(AvalonQuest *)quest gameState:(AvalonGame *)state;

- (BOOL)passQuest:(AvalonQuest *)quest gameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end