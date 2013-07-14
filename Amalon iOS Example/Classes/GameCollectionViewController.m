//
//  GameCollectionViewController.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "GameCollectionViewController.h"
#import "AmalonGameController.h"
#import <Amalon/JavaScriptDecider.h>

#define kNoButton 1
#define kYesButton 2

static NSString * const AMLGameCollectionViewPlayerCell = @"PLAYERCELL";
static NSString * const AMLGameCollectionViewSummaryCell = @"SUMMARYCELL";

@interface PlayerCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *roleLabel;
@property (nonatomic, strong) UIView *shieldIcon;
@property (nonatomic, strong) UIView *voteIcon;
@property (nonatomic, strong) UIView *leaderIcon;
@end

@interface SummaryCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *stepButton;
@property (nonatomic, strong) UIButton *yesButton;
@property (nonatomic, strong) UIButton *noButton;
@end

typedef NS_ENUM(NSInteger, AmalonInteractionState)
{
    AmalonInteractionStateStep = 1,
    AmalonInteractionStateProposal,
    AmalonInteractionStateVote,
    AmalonInteractionStateQuest,
    AmalonInteractionStateAssassinate
};

@interface GameCollectionViewController () <AvalonGameDelegate, AvalonAsyncDecider>
@property (nonatomic, strong) AmalonGameController *gameController;
@property (nonatomic, assign) AmalonInteractionState interactionState;

@property (nonatomic, copy) QuestProposalCallback proposalCallback;
@property (nonatomic, copy) BooleanCallback booleanCallback;
@property (nonatomic, copy) PlayerIdCallback assassinationCallback;

@property (nonatomic, strong) AvalonGame *displayGame;
@property (nonatomic, strong) NSString *playerIdForDispaly;

@property (nonatomic, strong) id<AvalonAsyncDecider> jsDecider;

@end

@implementation GameCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _gameController = [AmalonGameController new];
        _gameController.delegate = self;
        _displayGame = _gameController.game;
    }
    return self;
}

- (void)addRandomPlayer
{
    NSInteger n = [self.gameController.game.players count];
    if (!self.jsDecider) self.jsDecider = [JavaScriptDecider deciderWithScript:BundledScript(@"simple_bot")];
    [self.gameController addPlayer:[NSString stringWithFormat:@"Player %d", n+1] decider:self.jsDecider];
    
    if (n < [self.gameController.game.players count]) {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:n inSection:0]]];
    }
}

- (void)addInteractivePlayer
{
    NSInteger n = [self.gameController.game.players count];
    [self.gameController addPlayer:@"Human" decider:self];
    self.playerIdForDispaly = @"Human";
    
    if (n < [self.gameController.game.players count]) {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:n inSection:0]]];
    }
}

- (void)startNewGame
{
    self.playerIdForDispaly = nil;
    [self.gameController startNewGameWithVariant:AvalonVariantDefault];
    self.displayGame = self.gameController.game;
    [self.collectionView reloadData];
}

- (void)stepGame
{
    [self.gameController stepGame];
}

- (void)gameStateChanged
{
    NSParameterAssert([[NSThread currentThread] isMainThread]);
    self.displayGame = self.playerIdForDispaly ? [self.gameController displayGameForPlayer:self.playerIdForDispaly] : self.gameController.game;
    [self.collectionView reloadData];
    AvalonGame *game = self.gameController.game;
    self.title = [NSString stringWithFormat:@"%d.%d (Good: %d | Evil: %d)",
                  game.questNumber, game.voteNumber, game.passedQuestCount, game.failedQuestCount];
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
    
    UIBarButtonItem *y =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addInteractivePlayer)];
    
    UIBarButtonItem *s =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    self.navigationItem.rightBarButtonItems = @[s, a, s, n, s, y];
    
    self.collectionView.allowsMultipleSelection = YES;
    
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)addAction:(SEL)action toButton:(UIButton *)button
{
    if ([[button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1) {
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)vote:(UIButton *)sender
{
    if (self.booleanCallback) {
        self.booleanCallback(sender.tag == kYesButton);
        self.interactionState = AmalonInteractionStateStep;
        self.booleanCallback = nil;
    }
    if (self.proposalCallback && [self.collectionView.indexPathsForSelectedItems count] == [self selectionSize]) {
        NSMutableArray *ids = [NSMutableArray new];
        for (NSIndexPath *ip in self.collectionView.indexPathsForSelectedItems) {
            [ids addObject:[self.gameController.game.players[ip.item] playerId]];
        }
        self.proposalCallback([ids copy]);
        self.interactionState = AmalonInteractionStateStep;
        self.proposalCallback = nil;
    }
    if (self.assassinationCallback && [self.collectionView.indexPathsForSelectedItems count] == [self selectionSize]) {
        NSIndexPath *idx = [self.collectionView.indexPathsForSelectedItems lastObject];
        self.assassinationCallback([self.gameController.game.players[idx.item] playerId]);
        self.interactionState = AmalonInteractionStateStep;
        self.assassinationCallback = nil;
    }
}

#pragma mark - UICollectionView data source

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
    AvalonGame *g = self.displayGame;
    AvalonPlayer *p = g.players[index];
    cell.nameLabel.text = p.playerId;
    cell.roleLabel.text = p.role.name;
    if (g.currentQuest.currentProposal) {
        cell.shieldIcon.hidden = (g.state <= GameStateProposing || [g.currentQuest.currentProposal.players indexOfObject:p] == NSNotFound);
    } else {
        cell.shieldIcon.hidden = YES;
    }
    
    if ([g.currentLeader isEqual:p]) {
        cell.leaderIcon.hidden = NO;
    } else {
        cell.leaderIcon.hidden = YES;
    }
    
    if (g.state >= GameStateVotingCompleted) {
        NSNumber *v = g.currentQuest.currentProposal.votes[p.playerId];
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
            if (self.interactionState == AmalonInteractionStateProposal) {
                statusText = [NSString stringWithFormat:@"Select %d players to go on a quest", self.gameController.game.currentQuest.playerCount];
            } else {
                statusText = [NSString stringWithFormat:@"%@ is proposing Quest %d.%d",
                              self.gameController.game.currentLeader.playerId, self.gameController.game.questNumber, self.gameController.game.voteNumber];
            }
            break;
        
        case GameStateProposingCompleted:
            statusText = @"The quest has been proposed";
            break;
        
        case GameStateVoting:
            if (self.interactionState == AmalonInteractionStateVote) {
                statusText = @"Vote YES or NO for the proposed quest";
            } else {
                statusText = @"Players are voting for the proposed quest";
            }
            break;
            
        case GameStateVotingCompleted:
            statusText = @"The votes are in";
            break;
        
        case GameStateQuesting:
            if (self.interactionState == AmalonInteractionStateQuest) {
                statusText = @"PASS or FAIL the proposed quest";
            } else {
                statusText = @"The players are going on a quest";
            }
            break;
        
        case GameStateQuestingCompleted: {
            NSUInteger passes = self.gameController.game.currentQuest.currentProposal.numberOfPasses;
            NSUInteger fails = self.gameController.game.currentQuest.playerCount - passes;
            statusText = [NSString stringWithFormat:@"The players are back: %u Passes and %u Fails", passes, fails];
            break;
        }
            
        case GameStateAssassinating:
            if (self.interactionState == AmalonInteractionStateAssassinate) {
                statusText = @"Choose a player to assassinate";
            } else {
                statusText = @"The assassin is choosing a target";
            }
            break;
            
        case GameStateAssassinatingCompleted:
            statusText = [NSString stringWithFormat:@"%@ was assassinated", self.gameController.game.assassinatedPlayer];
            break;

        case GameStateEnded:
            statusText = [NSString stringWithFormat:@"%d - %d %@ was assassinated",
                          self.gameController.game.passedQuestCount, self.gameController.game.failedQuestCount, self.gameController.game.assassinatedPlayer ? self.gameController.game.assassinatedPlayer : @"No one"];
            break;
            
        default:
            break;
    }
    cell.statusLabel.text = statusText;
    
    [self addAction:@selector(stepGame) toButton:cell.stepButton];
    [self addAction:@selector(vote:) toButton:cell.yesButton];
    [self addAction:@selector(vote:) toButton:cell.noButton];
    
    switch (self.interactionState) {
        case AmalonInteractionStateAssassinate:
        case AmalonInteractionStateProposal:
        case AmalonInteractionStateVote:
        case AmalonInteractionStateQuest:
            cell.stepButton.hidden = YES;
            cell.yesButton.hidden = NO;
            cell.noButton.hidden = NO;
            break;
            
        case AmalonInteractionStateStep:
            cell.stepButton.hidden = NO;
            cell.yesButton.hidden = YES;
            cell.noButton.hidden = YES;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellID = indexPath.section == 0 ? AMLGameCollectionViewPlayerCell : AMLGameCollectionViewSummaryCell;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    
    if (indexPath.section == 0) {
        PlayerCell *pCell = (PlayerCell *)cell;
        [self configurePlayerCell:pCell forItemAtIndex:indexPath.item];
    } else {
        SummaryCell *sCell = (SummaryCell *)cell;
        [self configureSummaryCell:sCell];
    }
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (NSInteger)selectionSize
{
    NSInteger size = 0;
    switch (self.interactionState) {
        case AmalonInteractionStateAssassinate:
            size = 1;
            break;
            
        case AmalonInteractionStateProposal:
            size = self.gameController.game.currentQuest.playerCount;
            break;
            
        case AmalonInteractionStateVote:
        case AmalonInteractionStateQuest:
        case AmalonInteractionStateStep:
            size = 0;
            break;
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    };
    
    if ([self.collectionView.indexPathsForSelectedItems count] > [self selectionSize]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
}

#pragma mark - AvalonAsyncDecider

- (void)questProposalForGameState:(AvalonGame *)state callback:(QuestProposalCallback)block
{
    self.interactionState = AmalonInteractionStateProposal;
    self.proposalCallback = block;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
}

- (void)acceptProposalForGameState:(AvalonGame *)state callback:(BooleanCallback)block
{
    self.interactionState = AmalonInteractionStateVote;
    self.booleanCallback = block;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
}

- (void)passQuestForGameState:(AvalonGame *)state callback:(BooleanCallback)block
{
    self.interactionState = AmalonInteractionStateQuest;
    self.booleanCallback = block;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
}

- (void)playerIdToAssassinateForGameState:(AvalonGame *)state callback:(PlayerIdCallback)block
{
    self.interactionState = AmalonInteractionStateAssassinate;
    self.assassinationCallback = block;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
};

@end

#define DesiredLabelHeight 24.0f

@implementation PlayerCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize s = self.contentView.bounds.size;
    self.nameLabel.frame = CGRectInset(self.contentView.bounds, 10.0f, (s.height - DesiredLabelHeight)/2.0f);
    self.roleLabel.frame = CGRectOffset(self.nameLabel.frame, 0.0f, 4.0f + DesiredLabelHeight);
    self.roleLabel.numberOfLines = 2;
    self.shieldIcon.frame = CGRectMake(4.0f, 4.0f, 20.0f, 20.0f);
    self.voteIcon.frame = CGRectMake(s.width - 4.0f - 20.0f, 4.0f, 20.0f, 20.0f);
    self.leaderIcon.frame = CGRectMake(s.width- 4.0f - 20.0f, s.height - 4.0f - 20.0f, 20.0f, 20.0f);
    self.backgroundView.frame = self.contentView.bounds;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        _nameLabel = [UILabel new];
        [self.contentView addSubview:_nameLabel];
        
        _roleLabel = [UILabel new];
        _roleLabel.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:_roleLabel];
        
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
        
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor greenColor];
    }
    return self;
}

@end

@implementation SummaryCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize s = self.contentView.bounds.size;
    self.statusLabel.frame = CGRectInset(self.contentView.bounds, 10.0f, (s.height - DesiredLabelHeight)/2.0f);
    self.stepButton.frame = CGRectMake(s.width/2.0f - 40.0f, s.height - 40.0f - 40.0f, 80.0f, 40.0f);
    self.yesButton.frame = CGRectMake(20.0f, s.height - 40.0f - 40.0f, (s.width-40.0f-20.0f)/2.0f, 40.0f);
    self.noButton.frame = CGRectMake(20.0f + (s.width-40.0f-20.0f)/2.0f, s.height - 40.0f - 40.0f, (s.width-40.0f-20.0f)/2.0f, 40.0f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        _statusLabel = [UILabel new];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_statusLabel];
        
        _stepButton = [UIButton new];
        [_stepButton setTitle:@"Step" forState:UIControlStateNormal];
        [self.contentView addSubview:_stepButton];
        
        _yesButton = [UIButton new];
        [_yesButton setTitle:@"YES" forState:UIControlStateNormal];
        [_yesButton setBackgroundColor:[UIColor darkGrayColor]];
        _yesButton.hidden = YES;
        _yesButton.tag = kYesButton;
        [self.contentView addSubview:_yesButton];
        
        _noButton = [UIButton new];
        [_noButton setTitle:@"NO" forState:UIControlStateNormal];
        [_noButton setBackgroundColor:[UIColor lightGrayColor]];
        _noButton.hidden = YES;
        _noButton.tag = kNoButton;
        [self.contentView addSubview:_noButton];
    }
    return self;
}

@end