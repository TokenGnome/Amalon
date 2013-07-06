//
//  AvalonPlayer.m
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonPlayer.h"
#import "AvalonRole.h"

@implementation AvalonPlayer

+ (instancetype)playerWithId:(NSString *)playerId role:(AvalonRole *)role
{
    return [[self alloc] initWithId:playerId role:role];
}

+ (instancetype)playerWithId:(NSString *)playerId
{
    return [[self alloc] initWithId:playerId role:[AvalonRole roleWithType:AvalonRoleNone]];
}

+ (instancetype)anonymousPlayer
{
    return [[self alloc] initWithId:@"Anonymous" role:[AvalonRole roleWithType:AvalonRoleNone]];
}

- (instancetype)sanitizedForPlayer:(AvalonPlayer *)observer
{
    AvalonRoleType knownRoles = KnownRolesForRoleType(observer.role.type);
    AvalonRoleType sanitizedRole = (knownRoles & self.role.type) ? knownRoles : AvalonRoleNone;
    return [AvalonPlayer playerWithId:self.playerId role:[AvalonRole roleWithType:sanitizedRole]];
}

- (id)initWithId:(NSString *)playerId role:(AvalonRole *)role
{
    self = [super init];
    if (self) {
        _playerId = [playerId copy];
        _role = role;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.playerId, self.role.name];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && [self.playerId isEqualToString:[object playerId]];
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%@:%@", [self class], self.playerId] hash];
}

@end
