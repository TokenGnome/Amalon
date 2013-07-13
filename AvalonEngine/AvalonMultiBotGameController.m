//
//  AvalonMultiBotGameController.m
//  AvalonEngine
//
//  Created by Nathaniel Troutman on 7/12/13.
//  Copyright (c) 2013 TokenGnomeLLC. All rights reserved.
//


#import "AvalonMultiBotGameController.h"
#import "AvalonDecider.h"


@implementation AvalonMultiBotGameController

// Initialize the game controller with the engine, this will also associate this controller with the engine.
- (id) initWithEngine:(AvalonEngine *)engine {
    self = [super init];
    
    if (self) {
        _engine = engine;
        _engine.delegate = self;
        // Weak reference to the keys (which are players) means we won't be keeping players around if they are released by the game we are controlling
        // but we want strong references to the values (bots) as no one else is keeping track of them (hopefully)
        _botForPlayer = [NSMutableDictionary dictionary];

    }
    
    return self;
}

- (id) init {
    return [self initWithEngine:nil];
}



- (void) setBot:(id<AvalonDecider>)decider forPlayer:(AvalonPlayer *)player {
    NSLog(@"Setting decider for player [%@] to [%@]", player, decider);
    [self.botForPlayer setObject:decider forKey:player.playerId];
}

- (void)gameNeedsProposal:(AvalonGame *)game
{
    id<AvalonDecider> decider = [self.botForPlayer objectForKey:game.currentLeader.playerId];
    AvalonGame *state = [self.engine gameStateForPlayer:game.currentLeader.playerId game:game];
    NSArray *quest = [decider questProposalForGameState:state];    
    NSError *error = [self.engine proposeQuest:quest proposer:game.currentLeader.playerId game:game];
    if (error != nil)
        NSLog(@"%@", error);
}

- (void)gameNeedsVotes:(AvalonGame *)game
{
    for (AvalonPlayer *player in game.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        id<AvalonDecider> decider = [self.botForPlayer objectForKey:player.playerId];
        BOOL vote = [decider acceptProposalForGameState:state];        
        NSError *error = [self.engine acceptProposal:vote voter:player.playerId game:game];
        if (error != nil)
            NSLog(@"%@", error);
    }
}

- (void)gameNeedsPass:(AvalonGame *)game
{
    for (AvalonPlayer *player in game.currentQuest.currentProposal.players) {
        AvalonGame *state = [self.engine gameStateForPlayer:player.playerId game:game];
        id<AvalonDecider> decider = [self.botForPlayer objectForKey:player.playerId];
        BOOL vote = [decider passQuestForGameState:state];
        NSError *error = [self.engine passQuest:vote voter:player.playerId game:game];
        if (error != nil)
            NSLog(@"%@", error);
    }
}

- (void)gameNeedsAssassinationTarget:(AvalonGame *)game
{
    NSString *assassinId = [self.engine playerIdForRole:AvalonRoleAssassin game:game];
    AvalonGame *state = [self.engine gameStateForPlayer:assassinId game:game];
    id<AvalonDecider> decider = [self.botForPlayer objectForKey:assassinId];
    NSString *targetId = [decider playerIdToAssassinateForGameState:state];
    NSError *error = [self.engine assassinatePlayer:targetId assassin:assassinId game:game];
    if (error != nil)
        NSLog(@"%@", error);
}
@end
