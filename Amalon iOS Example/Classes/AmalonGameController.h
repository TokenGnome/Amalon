//
//  AmalonGameController.h
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Amalon/Avalon.h>

@protocol AvalonGameDelegate;

@interface AmalonGameController : NSObject <AvalonEngineDelegate>

@property (nonatomic, readonly) AvalonGame *game;
@property (nonatomic, weak) id<AvalonGameDelegate> delegate;

- (void)addPlayer:(NSString *)playerId decider:(id<AvalonAsyncDecider>)decider;

- (void)startNewGameWithVariant:(AvalonGameVariant)variant;

- (void)stepGame;

- (AvalonGame *)displayGameForPlayer:(NSString *)playerId;

@end

@protocol AvalonGameDelegate <NSObject>

- (void)gameStateChanged;

@end