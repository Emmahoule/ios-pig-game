//
//  GameStartNode.m
//  Cochon
//
//  Created by Emma Houlé on 21/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "GameStartNode.h"

@implementation GameStartNode

-(instancetype)init {
    if(self = [super init]) {
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Bebas"];
        label.fontSize = 32;
        label.color = [SKColor whiteColor];
        label.text = @"Save me !";
        [self addChild:label];
        
        label.alpha = 0;
        label.xScale = 0.2;
        label.yScale = 0.2;
        SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:2];
        SKAction *scaleIn = [SKAction scaleTo:1 duration:2];
        SKAction *fadeAndScale = [SKAction group:@[fadeIn, scaleIn]];
        [label runAction:fadeAndScale];
        
        SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"Bebas"];
        instructions.fontSize = 14;
        instructions.color = [SKColor whiteColor];
        instructions.text = @"Tap to start the game !";
        instructions.position = CGPointMake(0,-45);
        [self addChild:instructions];
        
        instructions.alpha = 0;
        SKAction *wait = [SKAction waitForDuration:4];
        SKAction *appear = [SKAction fadeAlphaTo:1 duration:0.2];
        SKAction *popUp = [SKAction scaleTo:1 duration:0.1];
        SKAction *dropdown = [SKAction scaleTo:1 duration:0.1];
        SKAction *pauseAndAppear = [SKAction sequence:@[wait, appear, popUp, dropdown]];
        SKAction *repeatForEver = [SKAction repeatActionForever:pauseAndAppear];
        [instructions runAction:repeatForEver];
        
        
    }
    
    return self;
}

@end
