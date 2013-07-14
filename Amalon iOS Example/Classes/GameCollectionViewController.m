//
//  GameCollectionViewController.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "GameCollectionViewController.h"
#import "AmalonGameController.h"
#import <Amalon/AbstractDecider.h>

static NSString * const AMLGameCollectionViewPlayerCell = @"PLAYERCELL";
static NSString * const AMLGameCollectionViewSummaryCell = @"SUMMARYCELL";

@interface PlayerCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *shieldIcon;
@property (nonatomic, strong) UIView *voteIcon;
@property (nonatomic, strong) UIView *leaderIcon;
@end

@interface SummaryCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *stepButton;
@end

@interface GameCollectionViewController ()
@property (nonatomic, strong) AmalonGameController *gameController;
@end

@implementation GameCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _gameController = [AmalonGameController new];
    }
    return self;
}

- (void)addRandomPlayer
{
    NSInteger n = [self.gameController.game.players count];
    [self.gameController addPlayer:[NSString stringWithFormat:@"Player %d", n+1] decider:[AbstractAsyncDecider new]];
    
    if (n < [self.gameController.game.players count]) {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:n inSection:0]]];
    }
}

- (void)startNewGame
{
    [self.gameController startNewGameWithVariant:AvalonVariantDefault];
    [self.collectionView reloadData];
}

- (void)stepGame
{
    [self.gameController stepGame];
    [self.collectionView reloadData];
    AvalonGame *game = self.gameController.game;
    self.title = [NSString stringWithFormat:@"%d.%d (Good: %d | Evil: %d)", game.questNumber, game.voteNumber, game.passedQuestCount, game.failedQuestCount];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[PlayerCell class] forCellWithReuseIdentifier:AMLGameCollectionViewPlayerCell];
    [self.collectionView registerClass:[SummaryCell class] forCellWithReuseIdentifier:AMLGameCollectionViewSummaryCell];
    
    UIBarButtonItem *a =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRandomPlayer)];
    
    UIBarButtonItem *n =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(startNewGame)];
    
    UIBarButtonItem *s =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    self.navigationItem.rightBarButtonItems = @[s, a, s, n, s];
    
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

#pragma UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return section == 0 ? [self.gameController.game.players count] : 1;
}

- (void)configurePlayerCell:(PlayerCell *)cell forItemAtIndex:(NSInteger)index
{
    AvalonPlayer *p = self.gameController.game.players[index];
    cell.nameLabel.text = p.playerId;
    if (self.gameController.game.currentQuest.currentProposal) {
        cell.shieldIcon.hidden = (self.gameController.game.state <= GameStateProposing || [self.gameController.game.currentQuest.currentProposal.players indexOfObject:p] == NSNotFound);
    } else {
        cell.shieldIcon.hidden = YES;
    }
    
    if ([self.gameController.game.currentLeader isEqual:p]) {
        cell.leaderIcon.hidden = NO;
    } else {
        cell.leaderIcon.hidden = YES;
    }
    
    if (self.gameController.game.state >= GameStateVotingCompleted) {
        NSNumber *v = self.gameController.game.currentQuest.currentProposal.votes[p.playerId];
        cell.voteIcon.backgroundColor = [v boolValue] ? [UIColor whiteColor] : [UIColor blackColor];
        cell.voteIcon.hidden = NO;
    } else {
        cell.voteIcon.hidden = YES;
    }
}

- (void)configureSummaryCell:(SummaryCell *)cell
{
    NSString *statusText;
    switch (self.gameController.game.state) {
        case GameStateNotStarted:
            statusText = @"Game has not started";
            break;
        
        case GameStateRolesAssigned:
            statusText = @"Roles have been assigned";
            break;
        
        case GameStateProposing:
            statusText = [NSString stringWithFormat:@"%@ is proposing Quest %d.%d", self.gameController.game.currentLeader.playerId, self.gameController.game.questNumber, self.gameController.game.voteNumber];
            break;
        
        case GameStateProposingCompleted:
            statusText = @"The quest has been proposed";
            break;
        
        case GameStateVoting:
            statusText = @"Players are voting for the proposed quest";
            break;
            
        case GameStateVotingCompleted:
            statusText = @"The votes are in";
            break;
        
        case GameStateQuesting:
            statusText = @"The players are going on a quest";
            break;
        
        case GameStateQuestingCompleted: {
            NSUInteger passes = self.gameController.game.currentQuest.currentProposal.numberOfPasses;
            NSUInteger fails = self.gameController.game.currentQuest.playerCount - passes;
            statusText = [NSString stringWithFormat:@"The players are back: %u Passes and %u Fails", passes, fails];
            break;
        }
            
        case GameStateAssassinating:
            statusText = @"The assassin is choosing a target";
            break;
            
        case GameStateAssassinatingCompleted:
            statusText = [NSString stringWithFormat:@"%@ was assassinated", self.gameController.game.assassinatedPlayer];
            break;

        case GameStateEnded:
            statusText = [NSString stringWithFormat:@"%d - %d %@ was assassinated", self.gameController.game.passedQuestCount, self.gameController.game.failedQuestCount, self.gameController.game.assassinatedPlayer ? self.gameController.game.assassinatedPlayer : @"No one"];
            break;
            
        default:
            break;
    }
    cell.statusLabel.text = statusText;
    
    if ([[cell.stepButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1) {
        [cell.stepButton addTarget:self action:@selector(stepGame) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellID = indexPath.section == 0 ? AMLGameCollectionViewPlayerCell : AMLGameCollectionViewSummaryCell;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = indexPath.section == 0 ? [UIColor lightGrayColor] : [UIColor blackColor];
    
    if (indexPath.section == 0) {
        PlayerCell *pCell = (PlayerCell *)cell;
        [self configurePlayerCell:pCell forItemAtIndex:indexPath.item];
    } else {
        SummaryCell *sCell = (SummaryCell *)cell;
        [self configureSummaryCell:sCell];
    }
    
    return cell;
}

@end

#define DesiredLabelHeight 24.0f

@implementation PlayerCell

- (void)layoutSubviews
{
    CGSize s = self.contentView.bounds.size;
    self.nameLabel.frame = CGRectInset(self.contentView.bounds, 10.0f, (s.height - DesiredLabelHeight)/2.0f);
    self.shieldIcon.frame = CGRectMake(4.0f, 4.0f, 20.0f, 20.0f);
    self.voteIcon.frame = CGRectMake(s.width - 4.0f - 20.0f, 4.0f, 20.0f, 20.0f);
    self.leaderIcon.frame = CGRectMake(s.width- 4.0f - 20.0f, s.height - 4.0f - 20.0f, 20.0f, 20.0f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _nameLabel = [UILabel new];
        [self.contentView addSubview:_nameLabel];
        
        _shieldIcon = [UIView new];
        _shieldIcon.backgroundColor = [UIColor yellowColor];
        _shieldIcon.hidden = YES;
        [self.contentView addSubview:_shieldIcon];
        
        _voteIcon = [UIView new];
        _voteIcon.backgroundColor = [UIColor whiteColor];
        _voteIcon.hidden = YES;
        [self.contentView addSubview:_voteIcon];
        
        _leaderIcon = [UIView new];
        _leaderIcon.backgroundColor = [UIColor blueColor];
        _leaderIcon.hidden = YES;
        [self.contentView addSubview:_leaderIcon];
    }
    return self;
}

@end

@implementation SummaryCell

- (void)layoutSubviews
{
    CGSize s = self.contentView.bounds.size;
    self.statusLabel.frame = CGRectInset(self.contentView.bounds, 10.0f, (s.height - DesiredLabelHeight)/2.0f);
    self.stepButton.frame = CGRectMake(s.width/2.0f - 40.0f, s.height - 40.0f - 40.0f, 80.0f, 40.0f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _statusLabel = [UILabel new];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.statusLabel];
        
        _stepButton = [UIButton new];
        [_stepButton setTitle:@"Step" forState:UIControlStateNormal];
        [self.contentView addSubview:self.stepButton];
        
    }
    return self;
}

@end