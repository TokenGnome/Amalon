//
//  AvalonMultiBotGameController.h
//  AvalonEngine
//
//  Created by Nathaniel Troutman on 7/12/13.
//  Copyright (c) 2013 TokenGnomeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvalonSimpleGameController.h"
#import "AvalonEngine.h"
#import "AvalonDecider.h"

@interface AvalonMultiBotGameController : NSObject <AvalonEngineDelegate>
@property (nonatomic, strong) AvalonEngine *engine;
@property (readonly) NSMutableDictionary *botForPlayer;

- (id) initWithEngine: (AvalonEngine *) engine;

- (void) setBot:(id<AvalonDecider>) decider forPlayer: (AvalonPlayer *) player;

@end
