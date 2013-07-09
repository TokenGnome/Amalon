//
//  ReplayViewController.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/6/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "ReplayViewController.h"
#import "QuestCell.h"
#import "AvalonEngine.h"
#import "AvalonGame.h"
#import "AvalonQuest.h"
#import "AvalonPlayer.h"
#import "AbstractDecider.h"
#import "JavaScriptDecider.h"

@interface ReplayViewController ()
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, strong) id<AvalonDecider> decider;
@property (nonatomic, strong) AvalonGame *game;

@end

@implementation ReplayViewController

- (void)startNewGame
{
    self.game = [AvalonGame new];
    
    [self.tableView reloadData];
    
    if (!self.decider) self.decider = [AbstractDecider new];
    
    [self.engine addPlayer:@"JT Bot 1" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JT Bot 2" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JT Bot 3" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JT Bot 4" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JT Bot 5" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JS Bot 1" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JS Bot 2" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JS Bot 3" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JS Bot 4" toGame:self.game decider:self.decider];
    [self.engine addPlayer:@"JS Bot 5" toGame:self.game decider:self.decider];
    
    [self.engine startGame:self.game withVariant:AvalonVariantNoOberon];
}

- (void)stepGame
{
    if (! self.game) [self startNewGame];
    
    NSInteger num = [[self proposals] count]
            , i = 10;
    
    while (i-- > 0 && num == [[self proposals] count]) {
        [self.engine step:self.game];
    }
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[self proposals] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (NSArray *)proposals
{
    NSMutableArray *prps = [NSMutableArray new];
    for (AvalonQuest *q in self.game.quests) {
        for (AvalonProposal *p in q.proposals) {
            [prps addObject:p];
        }
    }
    return prps;
}

- (NSArray *)votesforProposal:(AvalonProposal *)proposal
{
    NSMutableArray *a = [@[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0] mutableCopy];
    
    NSInteger i = 0;
    for (AvalonPlayer *p in self.game.players) {
        if (proposal.votes[p.playerId]) {
            a[i] = [proposal.votes[p.playerId] boolValue] ? @1 : @2;
        }
        i++;
    }
    return [a copy];
}

- (NSArray *)playersOnProposal:(AvalonProposal *)proposal
{
    NSMutableArray *a = [@[@NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO] mutableCopy];
    
    NSInteger i = 0;
    for (AvalonPlayer *p in self.game.players) {
        if ([proposal.players indexOfObject:p] != NSNotFound) {
            a[i] = @YES;
        }
        i++;
    }
    return [a copy];
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
    
    [self.tableView registerClass:[QuestCell class] forCellReuseIdentifier:@"CELL"];
    self.tableView.rowHeight = 100.0f;
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self proposals] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"CELL";
    
    AvalonProposal *prop = [self proposals][indexPath.row];
    QuestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.playersView.playerCount = [self.game.players count];
    cell.playersView.approved = [self votesforProposal:prop];
    cell.playersView.selected = [self playersOnProposal:prop];
    cell.questLabel.text = [NSString stringWithFormat:@"Quest: %d, Vote: %d", prop.questNumber, prop.voteNumber];
    
    return cell;
}

@end
