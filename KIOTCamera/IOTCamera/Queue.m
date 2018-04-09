//
//  Queue.m
//  IOTCamViewer
//
//  Created by tutk on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Queue.h"

@implementation NSMutableArray (QueueAdditions)

- (id)dequeue {
    
    id head = [self objectAtIndex:0];
    
    if (head != nil) {
        [[head retain] autorelease];
        [self removeObject:0];
    }
    
    return head;
}

- (void)enqueue:(id)object {
    
    [self addObject:object];
}

@end
