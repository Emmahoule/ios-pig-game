//
//  GameScene.m
//  Cochon
//
//  Created by Emma Houlé on 20/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "GameScene.h"
#import "Extensions.h"
@import SceneKit;


@interface GameScene ()

@property (nonatomic, weak) UITouch *pigTouch;
@property (nonatomic) NSTimeInterval lastUpdatedTime;

@end

@implementation GameScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        
        SKSpriteNode *cochon = [SKSpriteNode spriteNodeWithImageNamed:@"pig"];
        cochon.position = CGPointMake(size.width / 2, size.height / 2);
        cochon.zRotation = 0;
        [self addChild:cochon];
        
     }
    
    return self;
}


-(void)update:(NSTimeInterval)currentTime {
    
    //Gestion du temps
    if (self.lastUpdatedTime == 0) {
        self.lastUpdatedTime = currentTime;
    }
    NSTimeInterval delta = currentTime - self.lastUpdatedTime;
    if (self.pigTouch){
        CGPoint touchLocation = [self.pigTouch locationInNode:self];
        [self movePig:touchLocation byTimeDelta:delta];
    }
    self.lastUpdatedTime = currentTime;
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.pigTouch = [touches anyObject];
}


-(void)movePig:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta {

}







@end
