//
//  AmalonGameController.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AmalonGameController.h"

@interface AmalonGameController ()
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, strong) NSMutableDictionary *deciders;
@property (nonatomic, assign) BOOL steppingBlocked;
@end

@implementation AmalonGameController

- (id)init
{
    self = [super init];
    if (self) {
        _engine = [AvalonEngine engineWithDelegate:self];
        _deciders = [NSMutableDictionary new];
        [self setGame:[AvalonGame gameWithVariant:AvalonVariantDefault]];
    }
    return self;
}

- (void)dealloc
{
    if (self.game) [self.game removeObserver:self forKeyPath:@"state"];
}

- (void)setGame:(AvalonGame *)game
{
    if (_game) {
        [_game removeObserver:self forKeyPath:@"state"];
        _game = nil;
    }
    _game = game;
    [_game addObserver:self forKeyPath:@"state" options:kNilOptions context:NULL];
    self.deciders = [NSMutableDictionary new];
}

- (void)addPlayer:(NSString *)playerId decider:(id<AvalonAsyncDecider>)decider
{
    AvalonPlayer *player = [AvalonPlayer playerWithId:playerId];
    if ([self.engine canAddPlayer:player toGame:self.game]) {
        [self.game addPlayer:player];
        self.deciders[playerId] = decider;
    }
}

- (id<AvalonAsyncDecider>)deciderForPlayerId:(NSString *)playerId
{
    return self.deciders[playerId];
}

- (void)startNewGameWithVariant:(AvalonGameVariant)variant
{
    [self setGame:[AvalonGame gameWithVariant:variant]];
}

- (void)stepGame
{
    [self.engine step:self.game];
}

- (AvalonGame *)displayGameForPlayer:(NSString *)playerId
{
    return [self.engine gameStateForPlayer:playerId game:self.game];
}

#pragma mark - Game KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.delegate gameStateChanged];
}

#pragma mark - AvalonEngineDelegate

- (void)gameNeedsProposal:(AvalonGame *)game
{
    self.steppingBlocked = YES;
    NSString *playerId = game.currentLeader.playerId;
    AvalonGame *state = [self.engine gameStateForPlayer:playerId game:game];
    [[self deciderForPlayerId:playerId] questProposalForGameState:state callback:^(NSArray *proposal) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.engine proposeQuest:proposal proposer:game.currentLeader.playerId game:game];
            if (game.state == GameStateProposingCompleted) self.steppingBlocked = NO;
        }];
    }];
}

- (void)gameNeedsVotes:(AvalonGame *)game
{
    self.steppingBlocked = YES;
    for (AvalonPlayer *player in game.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        [[self deciderForPlayerId:player.playerId] acceptProposalForGameState:state callback:^(BOOL vote) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.engine acceptProposal:vote voter:player.playerId game:game];
                if (game.state == GameStateVotingCompleted) self.steppingBlocked = NO;
            }];
        }];
    }
}

- (void)gameNeedsPass:(AvalonGame *)game
{
    self.steppingBlocked = YES;
    for (AvalonPlayer *player in game.currentQuest.currentProposal.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        [[self deciderForPlayerId:player.playerId] passQuestForGameState:state callback:^(BOOL vote) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.engine passQuest:vote voter:player.playerId game:game];
                if (game.state == GameStateQuestingCompleted) self.steppingBlocked = NO;
            }];
        }];
    }
}

- (void)gameNeedsAssassinationTarget:(AvalonGame *)game
{
    self.steppingBlocked = YES;
    NSString *assassinId = [self.engine playerIdForRole:AvalonRoleAssassin game:game];
    AvalonGame *state = [self.engine gameStateForPlayer:assassinId game:game];
    [[self deciderForPlayerId:assassinId] playerIdToAssassinateForGameState:state callback:^(NSString *playerId) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.engine assassinatePlayer:playerId assassin:assassinId game:game];
            if (game.state == GameStateAssassinatingCompleted) self.steppingBlocked = NO;
        }];
    }];
}

@end
