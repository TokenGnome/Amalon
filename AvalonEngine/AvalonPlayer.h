//
//  AvalonPlayer.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AvalonRole;

@interface AvalonPlayer : NSObject

+ (instancetype)playerWithId:(NSString *)playerId role:(AvalonRole *)role;

+ (instancetype)playerWithId:(NSString *)playerId;

+ (instancetype)anonymousPlayer;

@property (nonatomic, strong) AvalonRole *role;

@property (nonatomic, copy) NSString *playerId;

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)observer;

@end
