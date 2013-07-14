//
//  AvalonDecider.h
//  AvalonEngine
//
//  Created by Nathaniel Troutman on 7/12/13.
//  Copyright (c) 2013 TokenGnomeLLC. All rights reserved.
//

#ifndef AvalonEngine_AvalonDecider_h
#define AvalonEngine_AvalonDecider_h

#import "AvalonEngine.h"

typedef void(^QuestProposalCallback)(NSArray *);
typedef void(^BooleanCallback)(BOOL);
typedef void(^PlayerIdCallback)(NSString *);

@protocol AvalonDecider <NSObject>

- (NSArray *)questProposalForGameState:(AvalonGame *)state;

- (BOOL)acceptProposalForGameState:(AvalonGame *)state;

- (BOOL)passQuestForGameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end

@protocol AvalonAsyncDecider <NSObject>

- (void)questProposalForGameState:(AvalonGame *)state callback:(QuestProposalCallback)block;

- (void)acceptProposalForGameState:(AvalonGame *)state callback:(BooleanCallback)block;

- (void)passQuestForGameState:(AvalonGame *)state callback:(BooleanCallback)block;

- (void)playerIdToAssassinateForGameState:(AvalonGame *)state callback:(PlayerIdCallback)block;

@end

#endif
