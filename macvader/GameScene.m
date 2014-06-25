//
//  GameScene.m
//  macvader
//
//  Created by juhana on 25/06/14.
//  Copyright (c) 2014 juhanapaavola. All rights reserved.
//

#import "GameScene.h"
#import "TitleScene.h"

static NSString* kPlayerName = @"player";

static const uint32_t SpriteColliderTypePlayer = 0x1 << 0;
static const uint32_t SpriteColliderTypeBullet = 0x1 << 1;
static const uint32_t SpriteColliderTypeEnemy = 0x1 << 2;
static const uint32_t SpriteColliderTypeEdge = 0x1 << 3;
static NSString* ScoreText = @"SCORE %05d";

@interface GameScene(){
    NSInteger accelX;
    BOOL playerShoot;
    CGRect shipMoveRect;
    CFTimeInterval oldTime;
    NSTimer* enemyTimer;
    NSTimer* starTimer;
    SKLabelNode* ScoreLabel;
    int Score;
}

@end
@implementation GameScene{
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"triangle"];
    sprite.scale = 0.3;
    [sprite setSpeed:1];
    [sprite setName:kPlayerName];
    [self addChild:sprite];
    
    CGSize ssize = CGSizeMake(sprite.size.width-10,sprite.size.height-10);
    sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ssize];
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = SpriteColliderTypePlayer;
    sprite.physicsBody.contactTestBitMask = SpriteColliderTypeEnemy;
    
    CGFloat x = view.scene.size.width/2;
    CGFloat y = 10+sprite.size.height;
    sprite.position = CGPointMake(x, y);
    shipMoveRect = CGRectMake(sprite.size.width/2, 0, view.scene.size.width-sprite.size.width/2, 0);
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody.categoryBitMask = SpriteColliderTypeEdge;
    
    enemyTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(spawnEnemy:) userInfo:nil repeats:YES];
    starTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(addStar:) userInfo:nil repeats:YES];
    
    
    ScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    ScoreLabel.text = [NSString stringWithFormat:ScoreText,0];
    ScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height-50);
    ScoreLabel.fontSize=50;
    [self addChild:ScoreLabel];
}

-(void)addStar:(NSTimer*)timer
{
    for(int i=0;i<8;i++){
        NSImage* img = [[NSImage alloc]initWithSize:CGSizeMake(32, 32)];
        [img lockFocus];
        NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, img.size.width, img.size.height) xRadius:10 yRadius:10];
        CGFloat rand = arc4random()%10+1;
        CGFloat alpha = rand/10;
        [[NSColor colorWithCalibratedRed:255 green:255 blue:255 alpha:alpha]set];
        [path fill];
        
        [img unlockFocus];
        
        SKTexture* texture = [SKTexture textureWithImage:img];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
        sprite.scale = 0.03;
        [self addChild:sprite];
        int max = self.size.width;
        CGFloat x = arc4random()%max;
        sprite.position = CGPointMake(x, self.size.height);
        NSTimeInterval time = arc4random()%5+2;
        SKAction* move = [SKAction moveByX:0 y:-self.size.height duration:time];
        [sprite runAction:move completion:^{
            [sprite removeFromParent];
        }];
    }
}

-(void)spawnEnemy:(NSTimer*)timer
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithImageNamed:@"redball"];
    node.scale=0.3;
    [self addChild:node];
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(node.size.width, node.size.height/2)];
    node.physicsBody.dynamic = YES;
    node.physicsBody.categoryBitMask = SpriteColliderTypeEnemy;
    node.physicsBody.contactTestBitMask = SpriteColliderTypePlayer;
    
    int max = [self size].width-node.size.width/2;
    int min = node.size.width/2;
    CGFloat x = arc4random()%max+min;
    CGFloat y = [self size].height-node.size.height;
    node.position = CGPointMake(x, y);
    
    SKAction* move = [SKAction moveByX:0 y:-self.size.height duration:3.0];
    [node runAction:move completion:^{
        [node removeFromParent];
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    SKSpriteNode* node = (SKSpriteNode*)[self childNodeWithName:kPlayerName];
    CGFloat x = accelX*5;
    CGFloat posx = node.position.x+x;
    if (posx>shipMoveRect.origin.x && posx<shipMoveRect.size.width) {
        node.position = CGPointMake(posx, node.position.y);
    }
    
    CFTimeInterval delta = currentTime-oldTime;
    if(playerShoot && delta>100){
        playerShoot=false;
        SKSpriteNode* bullet = [SKSpriteNode spriteNodeWithImageNamed:@"yellowball"];
        bullet.scale = 0.3;
        [self addChild:bullet];
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bullet.size.width/2, bullet.size.height/2)];
        bullet.physicsBody.dynamic = YES;
        bullet.physicsBody.categoryBitMask = SpriteColliderTypeBullet;
        bullet.physicsBody.contactTestBitMask = SpriteColliderTypeEnemy;
        
        CGFloat x = node.position.x;
        CGFloat y = node.position.y+node.size.height/2+bullet.size.height/2;
        bullet.position = CGPointMake(x, y);
        
        CGFloat moveY = [self size].height-y;
        SKAction* move = [SKAction moveByX:0 y:moveY duration:2.0];
        [bullet runAction:move completion:^{
            [bullet removeFromParent];
        }];
    }
}

-(void)keyDown:(NSEvent *)theEvent
{
    [self handleKeyEvent:theEvent keyDown:YES];
}

-(void)keyUp:(NSEvent *)theEvent
{
}

-(void)handleKeyEvent:(NSEvent*)theEvent keyDown:(BOOL)keyDown
{
    if([theEvent modifierFlags] & NSNumericPadKeyMask){
        NSString* theArrow = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        if([theArrow length]==1){
            keyChar = [theArrow characterAtIndex:0];
            switch (keyChar) {
                case NSLeftArrowFunctionKey:{
                    accelX=-1;
                }break;
                case NSRightArrowFunctionKey:{
                    accelX=1;
                }break;
                    
                default:
                    break;
            }
        }
    }
    
    NSString* chars = [theEvent characters];
    NSRange space = [chars rangeOfString:@" "];
    if(space.location!=NSNotFound){
        playerShoot=YES;
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if( (contact.bodyA.categoryBitMask & SpriteColliderTypeEnemy || contact.bodyB.categoryBitMask & SpriteColliderTypeEnemy) && ( (contact.bodyA.categoryBitMask & SpriteColliderTypeBullet || contact.bodyB.categoryBitMask & SpriteColliderTypeBullet) || (contact.bodyA.categoryBitMask & SpriteColliderTypePlayer || contact.bodyB.categoryBitMask & SpriteColliderTypePlayer))){
        [contact.bodyA.node runAction:[SKAction removeFromParent]];
        [contact.bodyB.node runAction:[SKAction removeFromParent]];
        
        if(contact.bodyA.categoryBitMask & SpriteColliderTypePlayer || contact.bodyB.categoryBitMask & SpriteColliderTypePlayer){
            [enemyTimer invalidate];
            [starTimer invalidate];
            enemyTimer=nil;
            starTimer=nil;
            TitleScene *scene = [TitleScene sceneWithSize:CGSizeMake(1024, 768)];
            scene.scaleMode = SKSceneScaleModeAspectFit;
            [self.scene.view presentScene:scene];
        }else{
            [self spawnEnemy:nil];
            Score+=5;
            ScoreLabel.text = [NSString stringWithFormat:ScoreText,Score];
        }
    }
}

@end
