//
//  AvalonRole.h
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Avalon.h"
#import "AvalonJSExports.h"

@interface AvalonRole : NSObject <AvalonRoleExport>

+ (instancetype)roleWithType:(AvalonRoleType)type;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) AvalonRoleType type;

@end
