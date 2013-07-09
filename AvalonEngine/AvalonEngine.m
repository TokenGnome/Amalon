//
//  AvalonEngine.m
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AvalonProposal.h"
#import "AvalonRole.h"

NSArray * GenerateRoles(AvalonGameVariant mask, NSUInteger playerCount)
{
    NSInteger numEvil = (playerCount == 5 | playerCount == 7) ? playerCount/2 : (playerCount/2) - 1;
    NSInteger numGood = playerCount - numEvil;
    
    NSMutableArray *roles = [NSMutableArray new];
    
    if (mask & AvalonRoleAssassin) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleAssassin]];
        numEvil--;
    }
    if (mask & AvalonRoleMorgana) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleMorgana]];
        numEvil--;
    }
    if (mask & AvalonRoleMordred) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleMordred]];
        numEvil--;
    }
    if (mask & AvalonRoleOberon) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleOberon]];
        numEvil--;
    }
    while (numEvil-- > 0) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleMinion]];
    }
    
    if (mask & AvalonRolePercival) {
        [roles addObject:[NSNumber numberWithInt:AvalonRolePercival]];
        numGood--;
    }
    if (mask & AvalonRoleMerlin) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleMerlin]];
        numGood--;
    }
    while (numGood-- > 0) {
        [roles addObject:[NSNumber numberWithInt:AvalonRoleServant]];
    }
    
    return [roles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSUInteger rndA, rndB;
        rndA = arc4random();
        rndB = arc4random();
        
        return rndA <= rndB ? NSOrderedAscending : NSOrderedDescending;
    }];
}

NSUInteger TeamSizeForQuestNumber(NSUInteger questNumber, NSUInteger playerCount)
{
    NSUInteger size;
    switch (playerCount) {
        case 5:
            size = [@[@2,@3,@2,@3,@3][questNumber-1] unsignedIntegerValue];
            break;
        case 6:
            size = [@[@2,@3,@4,@3,@4][questNumber-1] unsignedIntegerValue];
            break;
        case 7:
            size = [@[@2,@3,@3,@4,@4][questNumber-1] unsignedIntegerValue];
            break;
        case 8:
        case 9:
        case 10:
            size = [@[@3,@4,@4,@5,@5][questNumber-1] unsignedIntegerValue];
            break;
        default:
            size = 0;
            break;
    }
    return size;
}

NSUInteger FailsRequiredForQuestNumber(NSUInteger questNumber, NSUInteger playerCount)
{
    if (questNumber == 4 && playerCount > 6) return 2;
    return 1;
}

NSString *kAvalonRuleErrorDomain = @"com.tokengnome.avalon.error.rules";

@interface AvalonEngine ()
@property (nonatomic, assign) AvalonGameVariant variantMask;
@property (nonatomic, strong) NSMutableDictionary *deciders;
@end

@implementation AvalonEngine

#pragma mark - Constructors

+ (instancetype)engine
{
    AvalonEngine *eng = [AvalonEngine new];
    return eng;
}

- (id)init
{
    self = [super init];
    if (self) {
        _variantMask = AvalonVariantDefault;
        _deciders = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Simulated game loop

- (NSArray *)proposalForGame:(AvalonGame *)game
{
    id<AvalonDecider> controller = self.deciders[game.currentLeader.playerId];
    NSInteger teamSize = TeamSizeForQuestNumber(game.questNumber, [game.players count]);
    AvalonGame *state = [self gameStateForPlayer:game.currentLeader.playerId game:game];
    return [controller questProposalOfSize:teamSize gameState:state];
}

- (BOOL)voteForPlayer:(AvalonPlayer *)player game:(AvalonGame *)game
{
    id<AvalonDecider> controller = self.deciders[player.playerId];
    AvalonGame *state = [self gameStateForPlayer:player.playerId game:game];
    return [controller acceptProposalForGameState:state];
}

- (BOOL)passForPlayer:(AvalonPlayer *)player game:(AvalonGame *)game
{
    id<AvalonDecider> controller = self.deciders[player.playerId];
    AvalonGame *state = [self gameStateForPlayer:player.playerId game:game];
    return [controller passQuestForGameState:state];
}

- (NSString *)targetForAssassin:(NSString *)playerId game:(AvalonGame *)game
{
    id<AvalonDecider> controller = self.deciders[playerId];
    return [controller playerIdToAssassinateForGameState:game];
}

- (void)evaluateProposalForGame:(AvalonGame *)game
{
    game.state = GameStateVoting;
}

- (void)evaluateVotesForGame:(AvalonGame *)game
{
    if ([game.currentQuest.currentProposal isAccepted]) {
        game.state = GameStateQuesting;
    } else {
        game.voteNumber++;
        [self prepareForNextQuest:game];
    }
}

- (void)evaluatePassesForGame:(AvalonGame *)game
{
    [game.currentQuest isPass] ? game.passedQuestCount++ : game.failedQuestCount++;
    game.questNumber++;
    game.voteNumber = 1;
    [self prepareForNextQuest:game];
}

- (void)evaluateAssassinationForGame:(AvalonGame *)game
{
    game.state = GameStateEnded;
}

- (void)startGame:(AvalonGame *)game withVariant:(AvalonGameVariant)variant
{
    self.variantMask = variant;
}

- (void)step:(AvalonGame *)game
{
    switch (game.state) {
        
        case GameStateNotStarted: {
            NSError *error = [self assignRolesForGame:game variant:self.variantMask];
            if (error) NSLog(@"%@", error.userInfo[@"message"]);
            break;
        }
            
        case GameStateRolesAssigned: {
            [self startQuestsForGame:game];
            break;
        }
            
        case GameStateProposing: {
            // poll proposal
            NSArray *p = [self proposalForGame:game];
            [self proposeQuest:p proposer:game.currentLeader.playerId game:game];
            break;
        }
            
        case GameStateProposingCompleted: {
            [self evaluateProposalForGame:game];
            break;
        }
            
        case GameStateVoting: {
            // poll votes
            for (AvalonPlayer *player in game.players) {
                BOOL vote = [self voteForPlayer:player game:game];
                [self acceptProposal:vote voter:player.playerId game:game];
            }
            break;
        }
        
        case GameStateVotingCompleted: {
            [self evaluateVotesForGame:game];
            break;
        }
            
        case GameStateQuesting: {
            // poll passes
            for (AvalonPlayer *player in game.currentQuest.currentProposal.players) {
                BOOL vote = [self passForPlayer:player game:game];
                [self passQuest:vote voter:player.playerId game:game];
            }
            break;
        }
            
        case GameStateQuestingCompleted: {
            [self evaluatePassesForGame:game];
            break;
        }
        
        case GameStateAssassinating: {
            // poll target
            NSString *assassinId = [self playerIdForRole:AvalonRoleAssassin game:game];
            NSString *targetId = [self targetForAssassin:assassinId game:game];
            [self assassinatePlayer:targetId assassin:assassinId game:game];
            break;
        }
            
        case GameStateAssassinatingCompleted: {
            [self evaluateAssassinationForGame:game];
            break;
        }
            
        case GameStateEnded: {
            NSLog(@"Good: %d | Evil: %d", game.passedQuestCount, game.failedQuestCount);
            NSLog(@"Outcome:\n\t%@", [game.quests componentsJoinedByString:@"\n\t"]);
            NSLog(@"Assassinated player: %@", game.assassinatedPlayer);
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Player Management

- (NSString *)playerIdForRole:(AvalonRoleType)roleType game:(AvalonGame *)game
{
    for (AvalonPlayer *player in game.players) {
        if (player.role.type == roleType) return player.playerId;
    }
    return nil;
}

- (BOOL)canAddPlayer:(AvalonPlayer *)player toGame:(AvalonGame *)game
{
    if (game.state >= GameStateRolesAssigned) {
        NSLog(@"Attempting to add a player after roles are assigned is a no-op.");
        return NO;
    } else if ([game hasPlayer:player]) {
        NSLog(@"Attempting to add a player that already exists is a no-op.");
        return NO;
    } else if ([game.players count] >= AvalonMaxPlayerCount) {
        NSLog(@"Attempting to add a player to a full game is a no-op.");
        return NO;
    }
    return YES;
}

- (void)addPlayer:(NSString *)playerId toGame:(AvalonGame *)game decider:(id<AvalonDecider>)decider
{
    AvalonPlayer *player = [AvalonPlayer playerWithId:playerId];
    if (! [self canAddPlayer:player toGame:game]) return;
    
    [game.players addObject:player];
    self.deciders[playerId] = decider;
}

- (BOOL)canRemovePlayer:(AvalonPlayer *)player fromGame:(AvalonGame *)game
{
    if (game.state >= GameStateRolesAssigned) {
        NSLog(@"Attempting to remove a player after roles are assigned is a no-op.");
        return NO;
    } else if (! [game hasPlayer:player]) {
        NSLog(@"Attempting to remove a player that doesn't exists is a no-op.");
        return NO;
    }
    return YES;
}

- (void)removePlayer:(NSString *)playerId fromGame:(AvalonGame *)game
{
    AvalonPlayer *player = [AvalonPlayer playerWithId:playerId];
    if (! [self canRemovePlayer:player fromGame:game]) return;
    
    [game.players removeObject:player];
    [self.deciders removeObjectForKey:playerId];
    
}

#pragma mark - Role Assignment

- (BOOL)canAssignRolesForGame:(AvalonGame *)game error:(NSError **)error
{
    if (game.state >= GameStateRolesAssigned) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Roles have already been assigned."}];
        return NO;
    } else if ([game.players count] < AvalonMinPlayerCount || [game.players count] > AvalonMaxPlayerCount) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"There are too few/many players to assign roles."}];
        return NO;
    }
    return YES;
}

- (NSError *)assignRolesForGame:(AvalonGame *)game variant:(AvalonGameVariant)mask
{
    NSError *error = nil;
    if (! [self canAssignRolesForGame:game error:&error]) return error;
    
    NSArray *roles = GenerateRoles(mask, [game.players count]);
    NSUInteger idx = 0;
    for (AvalonPlayer *player in game.players) {
        NSNumber *boxedRoleType = roles[idx++];
        player.role = [AvalonRole roleWithType:[boxedRoleType intValue]];
    }
    game.state = GameStateRolesAssigned;
    return error;
}

#pragma mark - Quest Proposing

- (void)beginNewQuest:(AvalonGame *)game
{
    NSUInteger teamSize = TeamSizeForQuestNumber(game.questNumber, [game.players count]);
    NSUInteger failsReq = FailsRequiredForQuestNumber(game.questNumber, [game.players count]);
    game.currentQuest = [AvalonQuest questWithSize:teamSize number:game.questNumber failsRequired:failsReq];
    [game.quests addObject:game.currentQuest];
    game.state = GameStateProposing;
}

- (BOOL)canStartQuestsForGame:(AvalonGame *)game error:(NSError **)error
{
    if (game.state < GameStateRolesAssigned) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Roles must be assigned to start quests."}];
        return NO;
    } else if (game.state >= GameStateProposing) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Quests have already been started."}];
        return NO;
    }
    return YES;
}

- (NSError *)startQuestsForGame:(AvalonGame *)game
{
    NSError *error = nil;
    if (! [self canStartQuestsForGame:game error:&error]) return error;
    
    NSUInteger startIndex = arc4random() % [game.players count];
    game.currentLeader = game.players[startIndex];
    [self beginNewQuest:game];
    
    return error;
}

- (BOOL)isCurrentLeaderId:(NSString *)playerId forGame:(AvalonGame *)game
{
    return [game.currentLeader.playerId isEqualToString:playerId];
}

- (BOOL)canProposeQuest:(NSArray *)playerIds proposer:(NSString *)playerId game:(AvalonGame *)game error:(NSError **)error
{
    if (game.state != GameStateProposing) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Quests may not be proposed at this time."}];
        return NO;
    } else if (! [self isCurrentLeaderId:playerId forGame:game]) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"The quest proposer is not the current leader"}];
        return NO;
    } else if (! [game hasPlayers:playerIds]) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"All of the proposed players do not exist"}];
        return NO;
    }
    return YES;
}

- (NSError *)proposeQuest:(NSArray *)playerIds proposer:(NSString *)playerId game:(AvalonGame *)game
{
    NSError *error = nil;
    if (! [self canProposeQuest:playerIds proposer:playerId game:game error:&error]) return error;
    
    NSArray *players = [game playersWithIds:playerIds];
    AvalonProposal *prop = [AvalonProposal proposalWithPlayers:players proposer:game.currentLeader];
    [game.currentQuest addProposal:prop];
    game.state = GameStateProposingCompleted;
    return error;
}

#pragma mark - Quest Voting

- (BOOL)canVoteWithPlayer:(NSString *)playerId forGame:(AvalonGame *)game error:(NSError **)error
{
    if (game.state != GameStateVoting) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Votes may not be placed at this time."}];
        return NO;
    } else if (! [game playerWithId:playerId]) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Vote not recorded because player does not exist"}];
        return NO;
    }
    return YES;
}

- (BOOL)isVotingFinishedForGame:(AvalonGame *)game
{
    return [game.currentQuest.currentProposal.votes.allValues count] >= [game.players count];
}

- (NSError *)acceptProposal:(BOOL)vote voter:(NSString *)playerId game:(AvalonGame *)game
{
    NSError *error = nil;
    if (! [self canVoteWithPlayer:playerId forGame:game error:&error]) return error;

    AvalonPlayer *voter = [game playerWithId:playerId];
    [game.currentQuest.currentProposal setVote:vote forPlayer:voter];
    
    if ([self isVotingFinishedForGame:game]) {
        game.state = GameStateVotingCompleted;
    }
    return error;
}

#pragma mark - Assassination

- (BOOL)canAssassinatePlayer:(NSString *)playerId assassin:(NSString *)assassinId game:(AvalonGame *)game error:(NSError **)error
{
    return YES;
}

- (NSError *)assassinatePlayer:(NSString *)playerId assassin:(NSString *)assassinId game:(AvalonGame *)game
{
    NSError *error = nil;
    if (! [self canAssassinatePlayer:playerId assassin:assassinId game:game error:&error]) return error;
    
    game.assassinatedPlayer = [game playerWithId:playerId];
    game.state = GameStateAssassinatingCompleted;
    return error;
}

#pragma mark - Quest Resolving

- (BOOL)isQuestCompleteForGame:(AvalonGame *)game
{
    return [game.currentQuest isComplete];
}

- (BOOL)isQuestingFinishedForGame:(AvalonGame *)game
{
    if (game.voteNumber > 5) return YES;
    
    if (game.passedQuestCount > 2 || game.failedQuestCount > 2) return YES;
    
    return NO;
}

- (AvalonPlayer *)nextLeaderForGame:(AvalonGame *)game
{
    NSInteger idx = [game.players indexOfObject:game.currentLeader];
    NSInteger next = (idx + 1) % [game.players count];
    return game.players[next];
}

- (void)prepareForNextQuest:(AvalonGame *)game
{
    if ([self isQuestingFinishedForGame:game]) {
        game.state = (game.failedQuestCount < 3  && (self.variantMask & AvalonRoleAssassin)) ? GameStateAssassinating : GameStateEnded;
        return;
    }
    game.currentLeader = [self nextLeaderForGame:game];
    if ([self isQuestCompleteForGame:game]) {
        [self beginNewQuest:game];
    } else {
        game.state = GameStateProposing;
    }
}

- (BOOL)canPassWithPlayer:(NSString *)playerId game:(AvalonGame *)game error:(NSError **)error
{
    NSInteger idx = [game.currentQuest.currentProposal.players indexOfObject:[AvalonPlayer playerWithId:playerId]];
    if (idx == NSNotFound) {
        *error = [NSError errorWithDomain:kAvalonRuleErrorDomain code:1 userInfo:@{@"message": @"Player is not on the quest."}];
        return NO;
    }
    
    return YES;
}

- (NSError *)passQuest:(BOOL)vote voter:(NSString *)playerId game:(AvalonGame *)game
{
    NSError *error = nil;
    if (! [self canPassWithPlayer:playerId game:(AvalonGame *)game error:&error]) return error;
   
    AvalonPlayer *player = [game playerWithId:playerId];
    [game.currentQuest.currentProposal setPass:vote forPlayer:player];
    if ([self isQuestCompleteForGame:game]) {
        game.state = GameStateQuestingCompleted;
    }
    return error;
}

- (AvalonGame *)gameStateForPlayer:(NSString *)playerId game:(AvalonGame *)game
{
    AvalonPlayer *observer = [game playerWithId:playerId];
    if (! observer) observer = [AvalonPlayer anonymousPlayer];
    return [game sanitizedCopyForPlayer:observer];
}

@end
