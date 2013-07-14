//
//  AbstractDecider.h
//  
//
//  Created by Brandon Smith on 7/4/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "AvalonSimpleGameController.h"

@interface AbstractDecider : NSObject <AvalonDecider>

@end

@interface AbstractAsyncDecider : AbstractDecider <AvalonAsyncDecider>

@end
