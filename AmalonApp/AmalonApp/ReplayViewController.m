//
//  ReplayViewController.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "ReplayViewController.h"
#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AbstractDecider.h"

@interface ReplayViewController () <UITextViewDelegate>
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, strong) AvalonGame *game;

@property (nonatomic, strong) UITextView *textView;
@end

@implementation ReplayViewController

- (void)startNewGame
{
    self.textView.text = @"";
    self.game = [AvalonEngine newGame];
    [self.engine addPlayer:@"Native Bot 1" toGame:self.game decider:[AbstractDecider deciderWithId:@"Native Bot 1"]];
    [self.engine addPlayer:@"Native Bot 2" toGame:self.game decider:[AbstractDecider deciderWithId:@"Native Bot 2"]];
    [self.engine addPlayer:@"Native Bot 3" toGame:self.game decider:[AbstractDecider deciderWithId:@"Native Bot 3"]];
    [self.engine addPlayer:@"Native Bot 4" toGame:self.game decider:[AbstractDecider deciderWithId:@"Native Bot 4"]];
    [self.engine addPlayer:@"JS Bot 1" toGame:self.game decider:[AbstractDecider deciderWithId:@"JS Bot 1"]];
    [self.engine addPlayer:@"JS Bot 2" toGame:self.game decider:[AbstractDecider deciderWithId:@"JS Bot 2"]];
    [self.engine addPlayer:@"JS Bot 3" toGame:self.game decider:[AbstractDecider deciderWithId:@"JS Bot 3"]];
    [self.engine startGame:self.game withVariant:AvalonVariantNoOberon];
}

- (void)stepGame
{
    if (! self.game) [self startNewGame];
    
    [self.engine step:self.game];
    
    BOOL textAppended = NO;
    switch (self.game.state) {
        case GameStateRolesAssigned:
            [self appendText:[NSString stringWithFormat:
                              @"Game started:\n\t%@\n",
                              [self.game.players componentsJoinedByString:@"\n\t"]]];
            textAppended = YES;
            break;
            
        case GameStateProposingCompleted: {
            [self appendText:[NSString stringWithFormat:
                              @"[%d.%d] Proposed by %@:\n\t%@\n",
                              self.game.questNumber, self.game.voteNumber,
                              self.game.currentLeader.playerId,
                              [[self.game.currentQuest valueForKeyPath:@"players.playerId"] componentsJoinedByString:@"\n\t"]]];
            textAppended = YES;
            break;
        }
        case GameStateVotingCompleted: {            
            NSMutableArray *b = [NSMutableArray new];
            for (NSString *playerId in [self.game.currentQuest.votes.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
                NSString *result = [self.game.currentQuest.votes[playerId] boolValue] ? @"Accept" : @"Reject";
                [b addObject:[NSString stringWithFormat:@"%@ : %@", playerId, result]];
            }
            
            [self appendText:[NSString stringWithFormat:
                              @"[%d.%d] Votes:\n\t%@\n",
                              self.game.questNumber, self.game.voteNumber, [b componentsJoinedByString:@"\n\t"]]];
            textAppended = YES;
            break;
        }
        case GameStateQuestingCompleted: {
            NSMutableArray *b = [NSMutableArray new];
            for (NSNumber *result in self.game.currentQuest.results.allValues) {
                NSString *s = [result boolValue] ? @"PASS" : @"FAIL";
                [b addObject:s];
            }
            [self appendText:[NSString stringWithFormat:
                              @"[%d.%d] Result:\n\t%@\n",
                              self.game.questNumber, self.game.voteNumber, [b componentsJoinedByString:@"\n\t"]]];
            textAppended = YES;
            break;
        }
        case GameStateAssassinatingCompleted: {
            [self appendText:[NSString stringWithFormat:
                              @"%@ was assassinated\n",
                              self.game.assassinatedPlayer]];
            textAppended = YES;
            break;
        }
        case GameStateEnded: {
            [self appendText:[NSString stringWithFormat:
                              @"Game over.  Good: %d - Evil: %d",
                              self.game.passedQuestCount, self.game.failedQuestCount]];
            textAppended = YES;
            break;
        }
        default:
            break;
    }
    if (! textAppended) [self stepGame];
}

- (void)appendText:(NSString *)text
{
    NSString *currentText = self.textView.text;
    self.textView.text = [currentText stringByAppendingString:text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.engine = [AvalonEngine engine];
    
    // Button to start a new game
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"New Game" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startNewGame) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 100, 40);
    [button sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // Button to step current game
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Step" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(stepGame) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 100, 40);
    [button sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // Text view showing players
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.editable = NO;
    self.textView.delegate = self;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:48.0f/255.0f alpha:1.0f];
    self.textView.textColor = [UIColor colorWithRed:207.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1.0f];
    [self.view addSubview:self.textView];
}

@end
