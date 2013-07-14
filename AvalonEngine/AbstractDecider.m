//
//  AbstractDecider.m
//  
//
//  Created by Brandon Smith on 7/4/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AbstractDecider.h"
#import "AvalonSimpleGameController.h"

@implementation AbstractDecider

- (NSArray *)questProposalForGameState:(AvalonGame *)game
{
    NSMutableSet *set = [NSMutableSet new];
    NSUInteger size = game.currentQuest.playerCount;
    while ([set count] < size) {
        AvalonPlayer *p = game.players[arc4random()%game.players.count];
        [set addObject:p.playerId];
    }
    return [set allObjects];
}

- (BOOL)acceptProposalForGameState:(AvalonGame *)game
{
    BOOL vote = arc4random() % 2 == 0;
    vote = vote && (arc4random() % 2 == 0);
    if (game.currentQuest.currentProposal.voteNumber == 5) vote = YES;
    return vote;
}

- (BOOL)passQuestForGameState:(AvalonGame *)game
{
    BOOL passing = (game.observer.role.type & AvalonRoleGood);
    return passing || arc4random() % 2;
}

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)game
{
    AvalonPlayer *p = game.players[arc4random() % game.players.count];
    return p.playerId;
}

@end


@implementation AbstractAsyncDecider

- (void)questProposalForGameState:(AvalonGame *)state callback:(QuestProposalCallback)block
{
    block([super questProposalForGameState:state]);
}

- (void)acceptProposalForGameState:(AvalonGame *)state callback:(BooleanCallback)block
{
    block([super acceptProposalForGameState:state]);
}

- (void)passQuestForGameState:(AvalonGame *)state callback:(BooleanCallback)block
{
    block([super passQuestForGameState:state]);
}

- (void)playerIdToAssassinateForGameState:(AvalonGame *)state callback:(PlayerIdCallback)block
{
    block([super playerIdToAssassinateForGameState:state]);
}

@end
