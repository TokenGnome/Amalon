//
//  JavaScriptDecider.h
//  AmalonApp
//
//  Created by Brandon Smith on 7/7/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AbstractDecider.h"
#import "AvalonJSExports.h"

@interface JavaScriptDecider : AbstractDecider

+ (instancetype)deciderWithScript:(NSString *)script;

@end



