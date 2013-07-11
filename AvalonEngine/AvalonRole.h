//
//  AvalonRole.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonTypes.h"

@interface AvalonRole : NSObject

+ (instancetype)roleWithType:(AvalonRoleType)type;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) AvalonRoleType type;

@end
