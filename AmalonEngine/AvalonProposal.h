//
//  AvalonProposal.h
//  AmalonApp
//
//  Created by Brandon Smith on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonJSExports.h"

@class AvalonPlayer, AvalonQuest;

@interface AvalonProposal : NSObject <AvalonProposalExport>

+ (instancetype)proposalWithPlayers:(NSArray *)players proposer:(AvalonPlayer *)proposer;

@property (nonatomic, strong) AvalonPlayer *proposer;
@property (nonatomic, assign) NSUInteger questNumber;
@property (nonatomic, assign) NSUInteger voteNumber;
@property (nonatomic, assign) NSUInteger failsRequired;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSMutableDictionary *votes;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, assign, getter = isAccepted) BOOL accepted;
@property (nonatomic, assign, getter = isComplete) BOOL complete;
@property (nonatomic, assign, getter = isPass) BOOL passed;

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player;

- (void)setVote:(BOOL)vote forPlayer:(AvalonPlayer *)player;

- (void)setPass:(BOOL)vote forPlayer:(AvalonPlayer *)player;

@end
