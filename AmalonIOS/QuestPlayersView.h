//
//  QuestPlayersView
//  
//
//  Created by Smith, Brandon on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestPlayersView : UIView
@property (nonatomic, assign) NSUInteger playerCount;
@property (nonatomic, strong) NSArray *selected;
@property (nonatomic, strong) NSArray *approved;

@end
