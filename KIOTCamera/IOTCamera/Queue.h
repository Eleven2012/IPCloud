//
//  Queue.h
//  IOTCamViewer
//
//  Created by tutk on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id)dequeue;
- (void)enqueue:(id)object;
@end
