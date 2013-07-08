Amalon
======

An Avalon (Resistance) engine for simulating, replaying, or scripting games

## Current use case

Right now the engine can be used to run a non-interactive game using custom deciders (bots).

The AbstractDecider (seen below) implements the AvalonDecider protocol, but acts randomly.  It is intended to be subclassed.

```objective-c
AvalonEngine *engine = [AvalonEngine engine];
AvalonGame *game = [AvalonEngine newGame];
JavaScriptDecider *bot = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];

[engine addPlayer:@"Player1" toGame:game decider:bot];
[engine addPlayer:@"Player2" toGame:game decider:bot];
[engine addPlayer:@"Player3" toGame:game decider:bot];
[engine addPlayer:@"Player4" toGame:game decider:bot];
[engine addPlayer:@"Player5" toGame:game decider:bot];
[engine addPlayer:@"Player6" toGame:game decider:bot];
[engine addPlayer:@"Player7" toGame:game decider:bot];

[e startGame:g withVariant:variant];
while (! [g isFinished]) {
    [e step:g];
}

NSLog(@"Good: %d | Evil: %d", game.passedQuestCount, game.failedQuestCount);
NSLog(@"Outcome:\n\t%@", [game.quests componentsJoinedByString:@"\n\t"]);
NSLog(@"Assassinated player: %@", game.assassinatedPlayer);
```

## Creating deciders

### Native Deciders

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

### JavaScript Deciders

Deciders can also be implemented in javascript.  See the [wiki page](https://github.com/TokenGnome/Amalon/wiki/Using-JavaScript-for-Deciders)

random_bot.js is a very simple implementation in javascript.

## Example

Very crude example now included!

<img src="https://dl.dropboxusercontent.com/u/10407794/amalon.PNG" alt="Amalon" title="Amalon">