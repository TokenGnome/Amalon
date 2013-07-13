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

@protocol AvalonDecider <NSObject>

- (NSArray *)questProposalForGameState:(AvalonGame *)state;

- (BOOL)acceptProposalForGameState:(AvalonGame *)state;

- (BOOL)passQuestForGameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end

#endif
