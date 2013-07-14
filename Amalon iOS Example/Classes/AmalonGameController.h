//
//  AmalonGameController.h
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Amalon/Avalon.h>

@interface AmalonGameController : NSObject <AvalonEngineDelegate>

@property (nonatomic, readonly) AvalonGame *game;

- (void)addPlayer:(NSString *)playerId decider:(id<AvalonAsyncDecider>)decider;

- (void)startNewGameWithVariant:(AvalonGameVariant)variant;

- (void)stepGame;

@end
