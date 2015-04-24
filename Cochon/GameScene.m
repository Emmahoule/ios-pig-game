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
        pig.zPosition = 40;
        [self addChild:pig];
        
        // Train
        SKEmitterNode *train = [SKEmitterNode nodeWithFile:@"train.sks"];
        train.position = CGPointMake(-26,0);
        train.zRotation = 80;
        [pig addChild:train];
        
        
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
        [self changeDirectionPig:touchLocation byTimeDelta:delta];
    }
    self.lastUpdatedTime = currentTime;
    
    
    // Génération aléatoire de fermiers
    NSInteger dropGameObjectFrequency = 20;
    if(arc4random_uniform(3000)<= dropGameObjectFrequency) {
        [self dropGameObject];
    }


    [self movePigAndAnchor];
    [self moveFarmers];
    [self checkForCollision];
    [self enforceBoundaries];
    
    
//    NSLog(@"position anchor Point : %f ", self.anchorPoint.x);
//    NSLog(@"position cochon : %f ", pig.position.x);

    
}

-(void)enforceBoundaries {
    SKNode *pig = [self childNodeWithName:@"pig"];
    CGFloat largeurGame = 1500;
    CGFloat hauteurGame = 1500;
    if (pig.position.x > largeurGame) {
        pig.position = CGPointMake(-largeurGame, pig.position.y);
        self.anchorPoint = CGPointMake(largeurGame/self.size.width+0.5, self.anchorPoint.y);
        [self enforceBoundariesFarmer:-largeurGame y:0];
    }
    if (pig.position.x < -largeurGame) {
        pig.position = CGPointMake(largeurGame, pig.position.y);
        self.anchorPoint = CGPointMake(-largeurGame/self.size.width+0.5, self.anchorPoint.y);
        [self enforceBoundariesFarmer:largeurGame y:0];
    }
    if (pig.position.y > hauteurGame) {
        pig.position = CGPointMake(pig.position.x, -hauteurGame);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, hauteurGame/self.size.height+0.5);
        [self enforceBoundariesFarmer:0 y:-hauteurGame];
    }
    if (pig.position.y < -hauteurGame) {
        pig.position = CGPointMake(pig.position.x, hauteurGame);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, -hauteurGame/self.size.height+0.5);
        [self enforceBoundariesFarmer:0 y:hauteurGame];
    }
}

-(void)enforceBoundariesFarmer:(int)x y:(int)y {
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        farmer.position = CGPointMake(farmer.position.x + 2*x, farmer.position.y + 2*y);
    }];
}


-(void)movePigAndAnchor {
    // Faire bouger le cochon
    CGFloat pigSpeed = 8;
    SKNode *pig = [self childNodeWithName:@"pig"];
    CGFloat newX = pigSpeed * cos(pig.zRotation);
    CGFloat newY = pigSpeed * sin(pig.zRotation);
    pig.position = CGPointMake(pig.position.x + newX, pig.position.y + newY);
    
    // Faire bouger le point d'ancrage
    self.anchorPoint = CGPointMake(self.anchorPoint.x - newX/self.size.width,self.anchorPoint.y - newY/self.size.height);
}



-(void)moveFarmers {
    SKNode *pig = [self childNodeWithName:@"pig"];
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        CGFloat farmerSpeed = 6;
        CGFloat newXFarmer = farmerSpeed * cos(farmer.zRotation);
        CGFloat newYFarmer = farmerSpeed * sin(farmer.zRotation);
        farmer.position = CGPointMake(farmer.position.x + newXFarmer, farmer.position.y + newYFarmer);
        CGFloat angleIdeal = atan2f(pig.position.y-farmer.position.y, pig.position.x-farmer.position.x);
        if (farmer.zRotation > angleIdeal-0.08  && farmer.zRotation < angleIdeal+0.08) {
            farmer.zRotation = farmer.zRotation;
        }
        else if (angleIdeal > farmer.zRotation) {
            farmer.zRotation = farmer.zRotation + 0.08;
        }
        else if (angleIdeal < farmer.zRotation)  {
            farmer.zRotation = farmer.zRotation - 0.08;
        }
    }];
}



-(void)checkForCollision {
    SKNode *pig = [self childNodeWithName:@"pig"];
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        if ([pig intersectsNode:farmer]){
            [farmer removeFromParent];
            NSLog(@"Game Over !");
        }
    }];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.pigTouch = [touches anyObject];
}


-(void)changeDirectionPig:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta {
    CGPoint touchLocation = [self.pigTouch locationInNode:self];
    SKNode *pig = [self childNodeWithName:@"pig"];
    if (touchLocation.x>pig.position.x) {
        pig.zRotation = pig.zRotation + 0.1;
    }
    else {
        pig.zRotation = pig.zRotation - 0.1;
    }


}


-(void)dropGameObject{
    [self dropFarmer];
}

-(void)dropFarmer{
    SKSpriteNode *farmer = [SKSpriteNode spriteNodeWithImageNamed:@"farmer"];
    farmer.name = @"farmer";
    farmer.zPosition = 30;
    [self addChild:farmer];
}

@end
