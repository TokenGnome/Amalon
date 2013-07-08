//
//  AvalonJSExports.h
//  AmalonApp
//
//  Created by Brandon Smith on 7/7/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "Avalon.h"

@class AvalonGame, AvalonPlayer, AvalonQuest, AvalonRole;


@protocol AvalonGameExport <JSExport>

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

- (NSDictionary *)toJSON;

@end


@protocol AvalonPlayerExport <JSExport>

@property (nonatomic, strong) AvalonRole *role;
@property (nonatomic, copy) NSString *playerId;

- (NSDictionary *)toJSON;

@end


@protocol AvalonRoleExport <JSExport>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) AvalonRoleType type;

- (NSDictionary *)toJSON;

@end


@protocol AvalonQuestExport <JSExport>

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

- (NSDictionary *)toJSON;

@end

@protocol AvalonJSON <NSObject>

- (id)toJSON;

@end

@interface NSArray (AvalonJSON) <AvalonJSON>
@end

@interface NSDictionary (AvalonJSON) <AvalonJSON>
@end
