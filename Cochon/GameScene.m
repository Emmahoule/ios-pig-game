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
        
        // Pig
        SKSpriteNode *pig = [SKSpriteNode spriteNodeWithImageNamed:@"pig"];
        pig.position = CGPointMake(size.width / 2, size.height / 2);
        pig.zRotation = 0;
        pig.name = @"pig";
        pig.zPosition = 20;
        [self addChild:pig];
        
        
        // Tiled Background
        CGSize coverageSize = CGSizeMake(4000,4000); //the size of the entire image you want tiled
        CGRect textureSize = CGRectMake(0, 0, 500, 500); //the size of the tile.
        CGImageRef backgroundCGImage = [UIImage imageNamed:@"herbe_2"].CGImage; //change the string to your image name
        UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
        UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
        SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        backgroundTiles.yScale = -1; //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
        backgroundTiles.position = CGPointMake(0,0);
        backgroundTiles.name = @"background";
        backgroundTiles.zPosition = 0;
        [self addChild:backgroundTiles];
        
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
    
    // Faire bouger le cochon
    CGFloat pigSpeed = 3;
    SKNode *pig = [self childNodeWithName:@"pig"];
    CGFloat newX = pigSpeed * cos(pig.zRotation);
    CGFloat newY = pigSpeed * sin(pig.zRotation);
    pig.position = CGPointMake(pig.position.x + newX, pig.position.y + newY);
    
    self.anchorPoint = CGPointMake(self.anchorPoint.x - newX/self.size.width,self.anchorPoint.y - newY/self.size.height);
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.pigTouch = [touches anyObject];
}


-(void)movePig:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta {
    CGPoint touchLocation = [self.pigTouch locationInNode:self];
    SKNode *pig = [self childNodeWithName:@"pig"];
    if (touchLocation.x<self.view.bounds.size.width/2 + self.anchorPoint.x) {
        pig.zRotation = pig.zRotation + 0.1;
    }
    else {
        pig.zRotation = pig.zRotation - 0.1;
    }

}







@end
