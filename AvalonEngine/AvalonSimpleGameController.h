//
//  AvalonGameController.h
//  AmalonApp
//
//  Created by Smith, Brandon on 7/10/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonEngine.h"
#import "AvalonDecider.h"

@interface AvalonSimpleGameController : NSObject <AvalonEngineDelegate>
@property (nonatomic, strong) AvalonEngine *engine;
@property (nonatomic, strong) id<AvalonDecider> bot;

- (id) initWithEngine: (AvalonEngine *) engine;

@end

