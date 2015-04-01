//
//  GameScene.m
//  Cochon
//
//  Created by Emma Houlé on 20/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"
#import "Extensions.h"
#import "GameStartNode.h"

@implementation TitleScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        
        // Cochon
        SKSpriteNode *pig = [SKSpriteNode spriteNodeWithImageNamed:@"pig"];
        pig.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:pig];
        
        // Train
        SKEmitterNode *train = [SKEmitterNode nodeWithFile:@"train.sks"];
        train.position = CGPointMake(0,-40);
        [pig addChild:train];
        
        // Start game
        GameStartNode *gameStartNode = [GameStartNode node];
        gameStartNode.position = CGPointMake(self.size.width/2, self.size.height - 120);
        [self addChild:gameStartNode];
        
        //Hight Score
        NSNumberFormatter *scoreFormatter = [[NSNumberFormatter alloc] init];
        scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{@"hightscore":@0}];
        
        NSNumber *score = [defaults valueForKey:@"hightScore"];
        NSString *scoreText = [NSString stringWithFormat:@"HightScore : %@", [scoreFormatter stringFromNumber:score]];
        
        SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"Bebas"];
        instructions.fontSize = 16;
        instructions.fontColor = [SKColor whiteColor];
        instructions.text = scoreText;
        instructions.position = CGPointMake(self.size.width/2,70);
        [self addChild:instructions];
    
        
    }
    return self;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    GameScene *gameScene = [GameScene sceneWithSize:self.frame.size];
    SKTransition *transition = [SKTransition fadeWithDuration:1.0];
    [self.view presentScene:gameScene transition:transition];
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

}

@end
