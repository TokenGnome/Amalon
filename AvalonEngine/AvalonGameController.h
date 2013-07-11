//
//  AvalonGameController.h
//  AmalonApp
//
//  Created by Smith, Brandon on 7/10/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AvalonProposal.h"
#import "AvalonRole.h"

@protocol AvalonDecider;

@interface AvalonGameController : NSObject <AvalonEngineDelegate>
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, strong) id<AvalonDecider> bot;
@end

@protocol AvalonDecider <NSObject>

- (NSArray *)questProposalForGameState:(AvalonGame *)state;

- (BOOL)acceptProposalForGameState:(AvalonGame *)state;

- (BOOL)passQuestForGameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end
