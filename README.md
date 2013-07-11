Amalon
======

An Avalon (Resistance) engine for simulating, replaying, or scripting games

## Current use case

Right now the engine can be used to run a non-interactive game using custom deciders (bots).

```objective-c
AvalonGameController *c = [AvalonGameController new];
c.engine = [AvalonEngine engine];
c.engine.delegate = c;
c.bot = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];

AvalonGame *g = [AvalonGame gameWithVariant:AvalonVariantDefault];
for (int i = 1; i <= 10; i++) {
    AvalonPlayer *p = [AvalonPlayer playerWithId:[NSString stringWithFormat:@"BOT %d", i]];
    [g addPlayer:p];
}
while (! [g isFinished]) {
    [c.engine step:g];
}

BOOL goodWin = (g.passedQuestCount > g.failedQuestCount) && (g.assassinatedPlayer.role.type != AvalonRoleMerlin);
```

## Creating deciders

### Native Deciders

All deciders must implement the AvalonDecider protocol:

```objective-c
@protocol AvalonDecider <NSObject>

- (NSArray *)questProposalForGameState:(AvalonGame *)state;

- (BOOL)acceptProposalForGameState:(AvalonGame *)state;

- (BOOL)passQuestForGameState:(AvalonGame *)state;

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state;

@end
```

See the AbstractDecider class for an example implementation.

### JavaScript Deciders

Deciders can also be implemented in javascript using a similar interface:

```javascript
var proposeQuest = function(state) { /* array of player id strings */ };

var acceptProposal = function(state) { /* boolean for vote */ };

var passQuest = function(state) { /* boolean for pass */ };

var assassinatePlayer = function(state) { /* player id string to assassinate */ };
```

See the [wiki page](https://github.com/TokenGnome/Amalon/wiki/Using-JavaScript-for-Deciders)

## Example of iOS version

Update, getting prettier:

<img src="https://dl.dropboxusercontent.com/u/10407794/amalon2.PNG" alt="Amalon2" title="Amalon2">

Very crude example now included!

<img src="https://dl.dropboxusercontent.com/u/10407794/amalon.PNG" alt="Amalon" title="Amalon">