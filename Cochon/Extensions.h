//
//  Extensions.h
//  Cochon
//
//  Created by Emma Houlé on 21/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (Extensions)

+(SKEmitterNode *)nodeWithFile:(NSString *)filename;
-(void)dieInDuration:(NSTimeInterval)duration;

@end
