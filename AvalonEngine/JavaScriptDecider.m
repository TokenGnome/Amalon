//
//  JavaScriptDecider.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/7/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "JavaScriptDecider.h"

@implementation AvalonGame (JSDecider)
@end

@implementation AvalonPlayer (JSDecider)
@end

@implementation AvalonProposal (JSDecider)
@end

@implementation AvalonQuest (JSDecider)
@end

@implementation AvalonRole (JSDecider)
@end

@interface JavaScriptDecider ()
@property (nonatomic, strong) JSContext *context;
@end

@implementation JavaScriptDecider

+ (instancetype)deciderWithScript:(NSString *)script
{
    JavaScriptDecider *d = [self new];
    d.context = [JSContext new];
    [d.context evaluateScript:script];
    return d;
}

- (NSArray *)questProposalForGameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"proposeQuest"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toArray];
}

- (BOOL)acceptProposalForGameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"acceptProposal"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toBool];
}

- (BOOL)passQuestForGameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"passQuest"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toBool];
}

- (NSString *)playerIdToAssassinateForGameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"assassinatePlayer"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toString];
}

@end
