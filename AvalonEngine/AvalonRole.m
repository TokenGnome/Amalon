//
//  AvalonRole.m
//  
//
//  Created by Brandon Smith on 7/5/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonRole.h"

AvalonRoleType KnownRolesForRoleType(AvalonRoleType role)
{
    AvalonRoleType knownRoleTypes;
    
    switch (role) {
        case AvalonRoleServant:
            knownRoleTypes = AvalonRoleNone;
            break;
            
        case AvalonRoleMinion:
            knownRoleTypes = AvalonRoleEvilNotOberon;
            break;
            
        case AvalonRoleAssassin:
            knownRoleTypes = AvalonRoleEvilNotOberon;
            break;
            
        case AvalonRoleMerlin:
            knownRoleTypes = AvalonRoleEvilNotMordred;
            break;
            
        case AvalonRoleMordred:
            knownRoleTypes = AvalonRoleEvilNotOberon;
            break;
            
        case AvalonRoleMorgana:
            knownRoleTypes = AvalonRoleEvilNotOberon;
            break;
            
        case AvalonRolePercival:
            knownRoleTypes = AvalonRoleMerlinOrMorgana;
            break;
            
        case AvalonRoleOberon:
            knownRoleTypes = AvalonRoleNone;
            break;
            
        default:
            knownRoleTypes = AvalonRoleNone;
            break;
    }
    return knownRoleTypes;
}

NSString *NameForRoleType(AvalonRoleType role)
{
    NSString *name;
    
    switch (role) {
            
        case AvalonRoleServant:
            name = @"Loyal Servant of Arthur";
            break;
            
        case AvalonRoleMinion:
            name = @"Minion of Mordred";
            break;
            
        case AvalonRoleAssassin:
            name = @"Assassin";
            break;
            
        case AvalonRoleMerlin:
            name = @"Merlin";
            break;
            
        case AvalonRoleMordred:
            name = @"Mordred";
            break;
            
        case AvalonRoleMorgana:
            name = @"Morgana";
            break;
            
        case AvalonRolePercival:
            name = @"Percival";
            break;
            
        case AvalonRoleOberon:
            name = @"Oberon";
            break;
            
        case AvalonRoleEvilNotOberon:
            name = @"Non-Oberon Minion";
            break;
            
        case AvalonRoleEvilNotMordred:
            name = @"Non-Mordred Minion";
            break;
            
        case AvalonRoleMerlinOrMorgana:
            name = @"Merlin or Morgana";
            break;
            
        default:
            name = @"Unknown";
            break;
    }
    return name;
}

@implementation AvalonRole

+ (instancetype)roleWithType:(AvalonRoleType)type
{
    return [[self alloc] initWithType:type];
}

- (id)initWithType:(AvalonRoleType)type
{
    self = [super init];
    if (self) {
        _type = type;
        _name = NameForRoleType(type);
    }
    return self;
}

- (NSString *)description
{
    return self.name;
}

@end
