//
//  AvalonQuest.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AvalonPlayer, AvalonProposal;

@interface AvalonQuest : NSObject

+ (instancetype)questWithSize:(NSUInteger)numPlayers number:(NSUInteger)num failsRequired:(NSUInteger)numFails;

@property (nonatomic, readonly) NSUInteger questNumber;
@property (nonatomic, readonly) NSUInteger failsRequired;
@property (nonatomic, readonly) NSUInteger playerCount;
@property (nonatomic, strong) NSMutableArray *proposals;
@property (nonatomic, assign, getter = isComplete) BOOL complete;
@property (nonatomic, assign, getter = isPass) BOOL passed;

@property (nonatomic, readonly) AvalonProposal *currentProposal;

- (void)addProposal:(AvalonProposal *)proposal;

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)player;

@end
