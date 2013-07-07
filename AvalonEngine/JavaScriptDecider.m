//
//  JavaScriptDecider.m
//  AmalonApp
//
//  Created by Brandon Smith on 7/7/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "JavaScriptDecider.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JavaScriptDecider ()
@property (nonatomic, strong) JSContext *context;
@end

@implementation JavaScriptDecider

+ (instancetype)deciderWithId:(NSString *)playerId script:(NSString *)script
{
    JavaScriptDecider *d = [self deciderWithId:playerId];
    d.context = [JSContext new];
    [d.context evaluateScript:script];
    return d;
}

- (NSArray *)questProposalOfSize:(NSUInteger)size gameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"proposeQuest"];
    JSValue *result = [func callWithArguments:@[@(size), state]];
    return [result toArray];
}

- (BOOL)acceptProposal:(AvalonQuest *)quest gameState:(AvalonGame *)state
{
    JSValue *func = self.context[@"acceptProposal"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toBool];
}

- (BOOL)passQuest:(AvalonQuest *)quest gameState:(AvalonGame *)state
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

- (NSString *)dumpState:(AvalonGame *)state
{
    JSValue *func = self.context[@"dumpState"];
    JSValue *result = [func callWithArguments:@[state]];
    return [result toString];
}

@end
