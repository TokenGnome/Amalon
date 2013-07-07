//
//  AvalonQuest.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Avalon.h"
#import "AvalonJSExports.h"

@class AvalonPlayer;

@interface AvalonQuest : NSObject <AvalonQuestExport>

+ (instancetype)questWithPlayers:(NSArray *)players proposer:(AvalonPlayer *)proposer;

@property (nonatomic, strong) AvalonPlayer *proposer;
@property (nonatomic, assign) NSUInteger questNumber;
@property (nonatomic, assign) NSUInteger voteNumber;
@property (nonatomic, assign) NSUInteger failsRequired;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSMutableDictionary *votes;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, assign, getter = isAccepted) BOOL accepted;
@property (nonatomic, assign, getter = isComplete) BOOL complete;
@property (nonatomic, assign, getter = isSuccess) BOOL succeeded;

- (void)setVote:(BOOL)vote forPlayer:(AvalonPlayer *)player;

- (void)setPass:(BOOL)vote forPlayer:(AvalonPlayer *)player;

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player;

@end
