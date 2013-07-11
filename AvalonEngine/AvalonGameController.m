//
//  AvalonGameController.m
//  AmalonApp
//
//  Created by Smith, Brandon on 7/10/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonGameController.h"
#import "AvalonGame.h"
#import "AvalonPlayer.h"
#import "AvalonQuest.h"
#import "AvalonRole.h"

@implementation AvalonGameController

- (void)gameNeedsProposal:(AvalonGame *)game
{
    AvalonGame *state = [self.engine gameStateForPlayer:game.currentLeader.playerId game:game];
    NSArray *quest = [self.bot questProposalForGameState:state];
    NSError *error = [self.engine proposeQuest:quest proposer:game.currentLeader.playerId game:game];
    NSLog(@"%@", error);
}

- (void)gameNeedsVotes:(AvalonGame *)game
{
    for (AvalonPlayer *player in game.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        BOOL vote = [self.bot acceptProposalForGameState:state];
        NSError *error = [self.engine acceptProposal:vote voter:player.playerId game:game];
        NSLog(@"%@", error);
    }
}

- (void)gameNeedsPass:(AvalonGame *)game
{
    for (AvalonPlayer *player in game.currentQuest.currentProposal.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        BOOL vote = [self.bot passQuestForGameState:state];
        NSError *error = [self.engine passQuest:vote voter:player.playerId game:game];
        NSLog(@"%@", error);
    }
}

- (void)gameNeedsAssassinationTarget:(AvalonGame *)game
{
    NSString *assassinId = [self.engine playerIdForRole:AvalonRoleAssassin game:game];
    AvalonGame *state = [self.engine gameStateForPlayer:assassinId game:game];
    NSString *targetId = [self.bot playerIdToAssassinateForGameState:state];
    NSError *error = [self.engine assassinatePlayer:targetId assassin:assassinId game:game];
    NSLog(@"%@", error);
}

@end
