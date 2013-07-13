//
//  QuestCell.m
//  ViewCells
//
//  Created by Smith, Brandon on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "QuestCell.h"
#import "QuestPlayersView.h"

@implementation QuestCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame, remainder, left, right;
    CGFloat offset = self.contentView.bounds.size.height - (self.contentView.bounds.size.width / 10.0f);
    CGRectDivide(self.contentView.bounds, &remainder, &frame, offset - 6.0f, CGRectMinYEdge);
    self.playersView.frame = CGRectInset(frame, 10.0f, 0.0f);
    [self.playersView setNeedsDisplay];
    
    CGRectDivide(remainder, &right, &left, 40.0f, CGRectMaxXEdge);
    self.questLabel.frame = CGRectInset(left, 10.0f, 0.0f);
    [self.questLabel setNeedsDisplay];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.playersView = [QuestPlayersView new];
        [self.contentView addSubview:self.playersView];
        
        self.questLabel = [UILabel new];
        [self.contentView addSubview:self.questLabel];
    }
    return self;
}

@end
