//
//  GameScene.m
//  Cochon
//
//  Created by Emma Houlé on 20/03/2015.
//  Copyright (c) 2015 Lyon 2. All rights reserved.
//

#import "GameScene.h"
#import "Extensions.h"
#import "GameOverScene.h"
@import SceneKit;


@interface GameScene ()

@property (nonatomic, weak) UITouch *pigTouch;
@property (nonatomic) NSTimeInterval lastUpdatedTime;
@end

@implementation GameScene



// Initialisation des variables globales
int nbrfarmer = 0; // Comptera le nombre de fermiers présents sur la scène
double timer = 0; // Timer
bool nbrApple = false; // Booléen qui prendra vrai si le cochon mange une pomme
bool nbrSaucisson = false; // Booléen qui prendra vrai si le cochon mange un saucisson




// Initialisation de la scène
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Création et initialisation du cochon
        SKSpriteNode *pig = [SKSpriteNode spriteNodeWithImageNamed:@"pig"];
        pig.position = CGPointMake(size.width / 2, size.height / 2);
        pig.zRotation = 1.6;
        pig.name = @"pig";
        pig.zPosition = 40;
        [self addChild:pig];
        
        // Animation du cochon
        NSArray *spritePig = @[[SKTexture textureWithImageNamed:@"pig"],
                               [SKTexture textureWithImageNamed:@"pig2"]];
        SKAction *pigAnimation = [SKAction animateWithTextures:spritePig timePerFrame:0.1];
        SKAction *pigAnimationRepeat = [SKAction repeatActionForever:pigAnimation];
        [pig runAction:pigAnimationRepeat];
        
        
        // Création d'une forme circulaire autour du cochon qui va nous permettre de gérer au mieux les collisions.
        SKShapeNode *hitBox = [SKShapeNode shapeNodeWithCircleOfRadius:20];
        hitBox.name = @"hitBox";
        hitBox.alpha = 0;
        [pig addChild:hitBox];
    
        // Création de la trainée du cochon
        SKEmitterNode *train = [SKEmitterNode nodeWithFile:@"train.sks"];
        train.position = CGPointMake(-26,0);
        train.zRotation = 80;
        [pig addChild:train];
        
        // Faire boucler l'image d'arrière plan
        CGSize coverageSize = CGSizeMake(4000,4000);
        CGRect textureSize = CGRectMake(0, 0, 500, 500);
        CGImageRef backgroundCGImage = [UIImage imageNamed:@"herbe_2"].CGImage;
        UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
        UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
        SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        backgroundTiles.yScale = -1;
        backgroundTiles.position = CGPointMake(0,0);
        backgroundTiles.name = @"background";
        backgroundTiles.zPosition = 0;
        [self addChild:backgroundTiles];
        
        // Création d'un label pour le timer
        SKLabelNode *timerLabel = [SKLabelNode labelNodeWithFontNamed:@"helvetica"];
        timerLabel.text=@"0";
        timerLabel.name= @"timerLabel";
        timerLabel.position=CGPointMake(self.size.width/2, self.size.height/1.1);
        [self addChild:timerLabel];
        
    }
    
    return self;
}




// Fonction d'update
-(void)update:(NSTimeInterval)currentTime {
    
    // Gestion du temps
    if (self.lastUpdatedTime == 0) {
        self.lastUpdatedTime = currentTime;
    }
    NSTimeInterval delta = currentTime - self.lastUpdatedTime;

    // Appel de la fonction de changement de direction du cochon si il y a un événement (touch)
    if (self.pigTouch){
        CGPoint touchLocation = [self.pigTouch locationInNode:self];
        [self changeDirectionPig:touchLocation byTimeDelta:delta];
    }
    self.lastUpdatedTime = currentTime;

    // Calcul d'1 tour de rotation de cochon : 1 tour = une valeur de 6,3
    SKNode *pig = [self childNodeWithName:@"pig"];
    if ((pig.zRotation > 7.9) || (pig.zRotation < -4.7)) {
        pig.zRotation= 1.600000;
    }
    
    // Génération aléatoire des éléments du jeu
    NSInteger dropGameObjectFrequency = 20;
    if(arc4random_uniform(750)<= dropGameObjectFrequency) {
        [self dropGameObject];
    }

    // Gestion et update du timer
    timer += currentTime;
    SKLabelNode *timerLabel = [self childNodeWithName:@"timerLabel"];
    timerLabel.text = [NSString stringWithFormat:@"%3.0f",timer/1000000];
    

     // Appel de la fonction pour bouger le cochon, le pont d'ancrage et le timer en fonction de la vue
    [self movePigAndAnchor];
    
    // Appel de la fonction pour faire bouger les fermiers
    [self moveFarmers];
    
    // Appel de la fonction qui vérifie si les éléments arrivent sur le bord de l'écran, et les repositionne si besoin
    [self enforceBoundaries];
    
    // Appel de la fonction de vérification de collision
    [self checkForCollision];
}





// Générer aléatoirement des éléments du jeu
-(void)dropGameObject{
    u_int32_t dice = arc4random_uniform(100);
    if (dice <10) {
        [self dropSaucisson];
    }
    if (dice > 10 & dice < 20) {
        [self dropApple];
    }
    else if (dice <15) {
        [self dropDoubleFarmer];
    }
    else {
        [self dropFarmer];
    }
    
}



// Fonction qui créée des pommes et les positionne aléatoirement sur le terrain autour du cochon
-(void)dropApple{
    
    // On tire des nombres aléatoires pour déterminer des positions aléatoires
    int smallestAppleY = -160;
    int largestAppleY = 160;
    int randomAppleY = smallestAppleY + arc4random() %(largestAppleY+1-smallestAppleY);
    
    int smallestAppleX = -325;
    int largestAppleX = 325;
    int randomAppleX = smallestAppleX + arc4random() %(largestAppleX+1-smallestAppleX);
    
    // On position les pommes
    SKSpriteNode *apple = [SKSpriteNode spriteNodeWithImageNamed:@"pomme"];
    apple.name = @"apple";
    apple.zPosition = 30;
    SKNode *pig = [self childNodeWithName:@"pig"];
    apple.position = CGPointMake(pig.position.x + randomAppleY, pig.position.y+randomAppleX);
    [self addChild:apple];
}



// Fonction qui créée des saucissons et les positionne aléatoirement sur le terrain autour du cochon
-(void)dropSaucisson{
    
    // On tire des nombres aléatoires pour déterminer des positions aléatoires
    int smallestSaucissonY = -(self.size.width/2);
    int largestSaucissonY = self.size.width/2;
    int randomSaucissonY = smallestSaucissonY + arc4random() %(largestSaucissonY+1-smallestSaucissonY);
    
    int smallestSaucissonX = -(self.size.height/2);
    int largestSaucissonX =  self.size.height/2;
    int randomSaucissonX = smallestSaucissonX + arc4random() %(largestSaucissonX+1-smallestSaucissonX);
    
    // On position les saucissons
    SKSpriteNode *saucisson = [SKSpriteNode spriteNodeWithImageNamed:@"saucisson"];
    saucisson.name = @"saucisson";
    saucisson.zPosition = 30;
    SKNode *pig = [self childNodeWithName:@"pig"];
    saucisson.position = CGPointMake(pig.position.x + randomSaucissonY, pig.position.y+randomSaucissonX);
    [self addChild:saucisson];
}



// Fonction qui créée des fermiers et les positionne aléatoirement sur le terrain autour du cochon
-(void)dropFarmer{
    
    // On tire des nombres aléatoires pour déterminer des positions aléatoires
    int smallestY = -160;
    int largestY = 160;
    int randomY = smallestY + arc4random() %(largestY+1-smallestY);
    
    int smallestX = -325;
    int largestX = 325;
    int randomX = smallestX + arc4random() %(largestX+1-smallestX);
    
    // On position les fermiers
    SKSpriteNode *farmer = [SKSpriteNode spriteNodeWithImageNamed:@"farmer"];
    farmer.name = @"farmer";
    farmer.zPosition = 30;
    
    SKNode *pig = [self childNodeWithName:@"pig"];
    
    // Si le cochon se dirige vers le nord
    if (((pig.zRotation>1.6 && pig.zRotation<2.3875)) || ((pig.zRotation<7.9) && (pig.zRotation >7.1125))  ||  ((pig.zRotation<1.6) && (pig.zRotation >0.8125)) || ((pig.zRotation<-3.9125) && (pig.zRotation >-4.7))) {
        farmer.position = CGPointMake(pig.position.x +randomY, pig.position.y + self.size.height/2 + 20);
        farmer.zRotation = -(pig.zRotation);
    }
    // Si le cochon se dirige vers l'ouest
    else if ((pig.zRotation>2.3875 && pig.zRotation<3.9625) || (pig.zRotation>-3.9125 && pig.zRotation<-2.3375)) {
        farmer.position = CGPointMake(pig.position.x - self.size.width/2 - 20, pig.position.y +randomX);
        farmer.zRotation = 0;
    }
    // Si le cochon se dirige vers le sud
    else if ((pig.zRotation>3.9625 && pig.zRotation<5.5375) || (pig.zRotation>-2.3375 && pig.zRotation<-0.7625)) {
        farmer.position = CGPointMake(pig.position.x +randomY, pig.position.y - self.size.height/2 - 20);
    }
    // Si le cochon se dirige vers l'est
    else if ((pig.zRotation>5.5375 && pig.zRotation<7.9) || (pig.zRotation>-0.7625 && pig.zRotation<0.8125))  {
        farmer.position = CGPointMake(pig.position.x + self.size.width/2 + 20, pig.position.y +randomX);
        farmer.zRotation = -(pig.zRotation);
        farmer.zRotation = 3;
    }
    
    nbrfarmer ++;
    [self addChild:farmer];
    
    // Animer les fermiers
    NSArray *spriteFarmer = @[[SKTexture textureWithImageNamed:@"farmer"],
                              [SKTexture textureWithImageNamed:@"farmer2"]];
    SKAction *farmerAnimation = [SKAction animateWithTextures:spriteFarmer timePerFrame:0.1];
    SKAction *farmerAnimationRepeat = [SKAction repeatActionForever:farmerAnimation];
    [farmer runAction:farmerAnimationRepeat];
}




// Fonction qui créée des doubles fermiers et les positionne aléatoirement sur le terrain autour du cochon
-(void)dropDoubleFarmer{
    
    // On tire des nombres aléatoires pour déterminer des positions aléatoires
    int smallestY = -160;
    int largestY = 160;
    int randomY = smallestY + arc4random() %(largestY+1-smallestY);
    
    int smallestX = -325;
    int largestX = 325;
    int randomX = smallestX + arc4random() %(largestX+1-smallestX);
    
    // On position les doubles fermiers
    SKSpriteNode *farmer = [SKSpriteNode spriteNodeWithImageNamed:@"doublefarmer"];
    farmer.name = @"farmer";
    farmer.zPosition = 30;
    
    SKNode *pig = [self childNodeWithName:@"pig"];
    
    // Si le cochon se dirige vers le nord
    if (((pig.zRotation>1.6 && pig.zRotation<2.3875)) || ((pig.zRotation<7.9) && (pig.zRotation >7.1125))  ||  ((pig.zRotation<1.6) && (pig.zRotation >0.8125)) || ((pig.zRotation<-3.9125) && (pig.zRotation >-4.7))) {
        farmer.position = CGPointMake(pig.position.x +randomY, pig.position.y + self.size.height/2 + 20);
        farmer.zRotation = -(pig.zRotation);
    }
    // Si le cochon se dirige vers l'ouest
    else if ((pig.zRotation>2.3875 && pig.zRotation<3.9625) || (pig.zRotation>-3.9125 && pig.zRotation<-2.3375)) {
        farmer.position = CGPointMake(pig.position.x - self.size.width/2 - 20, pig.position.y +randomX);
        farmer.zRotation = 0;
    }
    // Si le cochon se dirige vers le sud
    else if ((pig.zRotation>3.9625 && pig.zRotation<5.5375) || (pig.zRotation>-2.3375 && pig.zRotation<-0.7625)) {
        farmer.position = CGPointMake(pig.position.x +randomY, pig.position.y - self.size.height/2 - 20);
    }
    // Si le cochon se dirige vers l'est
    else if ((pig.zRotation>5.5375 && pig.zRotation<7.9) || (pig.zRotation>-0.7625 && pig.zRotation<0.8125))  {
        farmer.position = CGPointMake(pig.position.x + self.size.width/2 + 20, pig.position.y +randomX);
        farmer.zRotation = -(pig.zRotation);
        farmer.zRotation = 3;
    }
    
    nbrfarmer ++;
    [self addChild:farmer];
    
    // Animer les doubles fermiers
    NSArray *spriteFarmer = @[[SKTexture textureWithImageNamed:@"doublefarmer"],
                              [SKTexture textureWithImageNamed:@"doublefarmer2"]];
    SKAction *farmerAnimation = [SKAction animateWithTextures:spriteFarmer timePerFrame:0.1];
    SKAction *farmerAnimationRepeat = [SKAction repeatActionForever:farmerAnimation];
    [farmer runAction:farmerAnimationRepeat];
    
}





// Fonction qui fait bouger le cochon, et en conséquence le point d'ancrage du jeu (caméra)
-(void)movePigAndAnchor {
    
    // Gestion de la vitesse du cochon
    CGFloat pigSpeed = 8;
    if (nbrApple == true) { // Si le cochon mange une pomme, il accélère
        pigSpeed = 9;
    }
    if (nbrSaucisson == true) { // Si le cochon mange une pomme, il ralenti
        pigSpeed = 7;
    }
    
    // Déplacer le cochon en fonction de sa rotation
    SKNode *pig = [self childNodeWithName:@"pig"];
    CGFloat newX = pigSpeed * cos(pig.zRotation);
    CGFloat newY = pigSpeed * sin(pig.zRotation);
    pig.position = CGPointMake(pig.position.x + newX, pig.position.y + newY);
    
    // Faire bouger le point d'ancrage pour qu'il suive le cochon (on garde le cochon au centre de l'écran)
    self.anchorPoint = CGPointMake(self.anchorPoint.x - newX/self.size.width,self.anchorPoint.y - newY/self.size.height);
    
    // Positionner le timer tout le temps en haut de l'écran
    SKNode *timerLabel = [self childNodeWithName:@"timerLabel"];
    timerLabel.position = CGPointMake(timerLabel.position.x + newX, timerLabel.position.y + newY);
    
}





// Fonction qui met en mouvement les fermiers
-(void)moveFarmers {
    
    // Récupération du cochon
    SKNode *pig = [self childNodeWithName:@"pig"];
    
    // Faire bouger chaque fermier en fonction de leur angle de rotation et de la position du cochon pour qu'ils le poursuivent
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        CGFloat farmerSpeed = 4.5;
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
        
        // supprimer les fermiers quand ils s'éloignent trop de la zone de vue du jeu
        if ((farmer.position.y>pig.position.y+self.size.height) || (farmer.position.y<pig.position.y-self.size.height) || (farmer.position.x>pig.position.x+self.size.width) || (farmer.position.x<pig.position.x-self.size.width)){
            [farmer removeFromParent];
            nbrfarmer--;
        }
    }];
}





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.pigTouch = [touches anyObject];
}





// Fonction qui permet de faire tourner le cochon en fonction d'un événement : toucher l'écran
-(void)changeDirectionPig:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta {
    CGPoint touchLocation = [self.pigTouch locationInNode:self];
    SKNode *pig = [self childNodeWithName:@"pig"];
    // Si le joueur touche la partie droite de l'écran
    if (touchLocation.x>pig.position.x) {
        pig.zRotation = pig.zRotation + 0.1;
    }
    // Si le joueur touche la partie gauche de l'écran
    else {
        pig.zRotation = pig.zRotation - 0.1;
    }
}




// Fonction qui repositionne les éléments s'ils dépassent les frontières du jeu
-(void)enforceBoundaries {
    
    // Récupération du noeud cochon et du noeud timer
    SKNode *pig = [self childNodeWithName:@"pig"];
    SKNode *timerLabel = [self childNodeWithName:@"timerLabel"];
    
    // Définition des dimensions du jeu
    CGFloat largeurGame = 1500;
    CGFloat hauteurGame = 1500;
    
    // Si le chochon dépasse la frontière droite
    if (pig.position.x > largeurGame) {
        pig.position = CGPointMake(-largeurGame, pig.position.y);
        timerLabel.position = CGPointMake(-largeurGame, timerLabel.position.y);
        self.anchorPoint = CGPointMake(largeurGame/self.size.width+0.5, self.anchorPoint.y);
        [self enforceBoundariesFarmer:-largeurGame y:0];
    }
    
    // Si le chochon dépasse la frontière gauche
    if (pig.position.x < -largeurGame) {
        pig.position = CGPointMake(largeurGame, pig.position.y);
        timerLabel.position = CGPointMake(largeurGame, timerLabel.position.y);
        self.anchorPoint = CGPointMake(-largeurGame/self.size.width+0.5, self.anchorPoint.y);
        [self enforceBoundariesFarmer:largeurGame y:0];
    }
    
    // Si le chochon dépasse la frontière haute
    if (pig.position.y > hauteurGame) {
        pig.position = CGPointMake(pig.position.x, -hauteurGame);
        timerLabel.position = CGPointMake(timerLabel.position.x, -hauteurGame+230);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, hauteurGame/self.size.height+0.5);
        [self enforceBoundariesFarmer:0 y:-hauteurGame];
    }
    
    // Si le chochon dépasse la frontière basse
    if (pig.position.y < -hauteurGame) {
        pig.position = CGPointMake(pig.position.x, hauteurGame);
        timerLabel.position = CGPointMake(timerLabel.position.x, hauteurGame+230);
        self.anchorPoint = CGPointMake(self.anchorPoint.x, -hauteurGame/self.size.height+0.5);
        [self enforceBoundariesFarmer:0 y:hauteurGame];
    }
}





// Fonction repositionne les fermier s'ils dépassent les frontières du jeu
-(void)enforceBoundariesFarmer:(int)x y:(int)y {
    
    // Énumération de la liste des fermiers présents sur la scène
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        farmer.position = CGPointMake(farmer.position.x + 2*x, farmer.position.y + 2*y);
    }];
}




// Fonction qui vérifie s'il y a des collisions entre le cochon et les divers éléments du jeu
-(void)checkForCollision {
    SKNode *pig = [self childNodeWithName:@"pig"];
    SKNode *hitBox = [pig childNodeWithName:@"hitBox"];
    
    // Si la forme ronde du cochon heurte un fermier
    [self enumerateChildNodesWithName:@"farmer" usingBlock:^(SKNode *farmer, BOOL *stop) {
        if ([hitBox intersectsNode:farmer]){
            NSLog(@"Game Over !");
            [self runAction:[SKAction playSoundFileNamed:@"snorting.mp3" waitForCompletion:NO]];
            nbrfarmer = 0;
            timer = 0;
            GameOverScene *gameOverScene = [GameOverScene sceneWithSize:self.frame.size];
            [self.view presentScene:gameOverScene];
        }
    }];
    
    // Si la forme ronde du cochon heurte un double fermier
    [self enumerateChildNodesWithName:@"doublefarmer" usingBlock:^(SKNode *doublefarmer, BOOL *stop) {
        if ([hitBox intersectsNode:doublefarmer]){
            nbrfarmer--;
            [self runAction:[SKAction playSoundFileNamed:@"snorting.mp3" waitForCompletion:NO]];
            timer = 0;
            GameOverScene *gameOverScene = [GameOverScene sceneWithSize:self.frame.size];
            [self.view presentScene:gameOverScene];
        }
    }];
    
    // Si la forme ronde du cochon heurte une pomme
    [self enumerateChildNodesWithName:@"apple" usingBlock:^(SKNode *apple, BOOL *stop) {
    if ([hitBox intersectsNode:apple]){
        [apple removeFromParent];
        nbrApple = true;
        nbrSaucisson = false ;
        [self runAction:[SKAction playSoundFileNamed:@"eat.mp3" waitForCompletion:NO]];

        }
    }];
    
    // Si la forme ronde du cochon heurte un saucisson
    [self enumerateChildNodesWithName:@"saucisson" usingBlock:^(SKNode *saucisson, BOOL *stop) {
        if ([hitBox intersectsNode:saucisson]){
            [saucisson removeFromParent];
            nbrSaucisson = true ;
            nbrApple = false ;
            [self runAction:[SKAction playSoundFileNamed:@"eat2.mp3" waitForCompletion:NO]];

        }
    }];
}


@end
