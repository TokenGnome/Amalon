//
//  AbstractDecider.m
//  
//
//  Created by Brandon Smith on 7/4/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AbstractDecider.h"
#import "AvalonGame.h"
#import "AvalonPlayer.h"
#import "AvalonQuest.h"
#import "AvalonRole.h"

@implementation AbstractDecider

- (NSArray *)questProposalOfSize:(NSUInteger)size gameState:(AvalonGame *)game
{
    NSMutableSet *set = [NSMutableSet new];
    while ([set count] < size) {
        AvalonPlayer *p = game.players[arc4random()%game.players.count];
        [set addObject:p.playerId];
    }
    return [set allObjects];
}

- (BOOL)acceptProposal:(AvalonQuest *)proposal gameState:(AvalonGame *)game
{
    BOOL vote = arc4random() % 2 == 0;
    vote = vote && (arc4random() % 2 == 0);
    if (proposal.voteNumber == 5) vote = YES;
    return vote;
}

- (BOOL)passQuest:(AvalonQuest *)proposal gameState:(AvalonGame *)game
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
