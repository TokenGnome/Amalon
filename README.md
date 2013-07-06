Amalon
======

An Avalon (Resistance) engine for simulating, replaying, or scripting games

## Current use case

Right now the engine can be used to run a non-interactive game using custom deciders (bots).

The AbstractDecider (seen below) implements the AvalonDecider protocol, but acts randomly.  It is intended to be subclassed.

```objective-c
AvalonEngine *engine = [AvalonEngine engine];
AvalonGame *game = [AvalonEngine newGame];

[engine addPlayer:@"Player1" toGame:game decider:[AbstractDecider deciderWithId:@"Player1"]];
[engine addPlayer:@"Player2" toGame:game decider:[AbstractDecider deciderWithId:@"Player2"]];
[engine addPlayer:@"Player3" toGame:game decider:[AbstractDecider deciderWithId:@"Player3"]];
[engine addPlayer:@"Player4" toGame:game decider:[AbstractDecider deciderWithId:@"Player4"]];
[engine addPlayer:@"Player5" toGame:game decider:[AbstractDecider deciderWithId:@"Player5"]];
[engine addPlayer:@"Player6" toGame:game decider:[AbstractDecider deciderWithId:@"Player6"]];
[engine addPlayer:@"Player7" toGame:game decider:[AbstractDecider deciderWithId:@"Player7"]];

[engine runGame:game withVariant:AvalonVariantNoOberon];

NSLog(@"Good: %d | Evil: %d", game.passedQuestCount, game.failedQuestCount);
NSLog(@"Outcome:\n\t%@", [game.quests componentsJoinedByString:@"\n\t"]);
NSLog(@"Assassinated player: %@", game.assassinatedPlayer);
```

## Creating deciders

All deciders must implement the AvalonDecider protocol:

```objective-c
@property (nonatomic, strong) AvalonRole *role;

@property (nonatomic, copy) NSString *playerId;

- (NSArray *)questProposalOfSize:(NSUInteger)size gameState:(AvalonGame *)state;

- (BOOL)acceptProposal:(AvalonQuest *)quest gameState:(AvalonGame *)state;

- (BOOL)passQuest:(AvalonQuest *)quest gameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;
```

See the AbstractDecider class for an example implementation.

## Example

Example app coming soon.