//
//  GameOverScene.m
//  Cochon
//
//  Created by Emma Houlé on 24/04/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "Extensions.h"


@implementation GameOverScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Création d'un background image
        SKSpriteNode *bgImage = [SKSpriteNode spriteNodeWithImageNamed:@"backgroundgameover"];
        bgImage.position=CGPointMake(160,280);
        [self addChild:bgImage];
        [self runAction:[SKAction playSoundFileNamed:@"gameover.mp3" waitForCompletion:NO]];

        // Création d'un rectangle rose qui nous sert de fond pour nos instructions
        SKShapeNode *rect = [SKShapeNode shapeNodeWithRect:CGRectMake(-100, -10,200,30) cornerRadius:5];
        rect.fillColor = [UIColor colorWithRed:0.9529411765 green:0.6705882353 blue:0.7960784314 alpha:1.0];
        rect.strokeColor = [UIColor colorWithRed:0.9529411765 green:0.6705882353 blue:0.7960784314 alpha:1.0];
        rect.position = CGPointMake(self.size.width/2,self.size.height/2 );
        rect.zPosition = 50;
        rect.alpha = 0;
        [self addChild:rect];
        
        // Création des instructions
        SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"chunkfive"];
        instructions.fontSize = 14;
        instructions.color = [SKColor blackColor];
        instructions.text = @"Touchez l'écran pour rejouer !";
        instructions.position = CGPointMake(self.size.width/2,self.size.height/2 );
        instructions.zPosition = 80;
        [self addChild:instructions];
        
        // Animation des instructions et du rectangle
        instructions.alpha = 0;
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *appear = [SKAction fadeAlphaTo:1 duration:0.2];
        SKAction *popUp = [SKAction scaleTo:1 duration:0.5];
        SKAction *dropdown = [SKAction scaleTo:1 duration:0.5];
        SKAction *pauseAndAppear = [SKAction sequence:@[wait, appear, popUp, dropdown]];
        SKAction *repeatForEver = [SKAction repeatActionForever:pauseAndAppear];
        [instructions runAction:repeatForEver];
        [rect runAction:repeatForEver];
        
    }
    return self;
}


// Fonction qui lance des actions après l'événement "Toucher l'écran tactile"
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Lancer une action pour jouer un son
    [self runAction:[SKAction playSoundFileNamed:@"snorting.mp3" waitForCompletion:NO]];
    
    // Création de la scène de jeu avec pour paramètre la taille de l'écran de jeu
    GameScene *gameScene = [GameScene sceneWithSize:self.frame.size];
    
    // Animation/transitions entre les 2 écrans
    SKTransition *transition = [SKTransition fadeWithDuration:1.0];
    [self.view presentScene:gameScene transition:transition];
}

@end
