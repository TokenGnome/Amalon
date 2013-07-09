//
//  QuestCell.h
//  ViewCells
//
//  Created by Smith, Brandon on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestPlayersView.h"

@interface QuestCell : UITableViewCell
@property (nonatomic, strong) UILabel *questLabel;
@property (nonatomic, strong) QuestPlayersView *playersView;
@end
