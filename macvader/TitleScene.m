//
//  TitleScene.m
//  macvader
//
//  Created by juhana on 25/06/14.
//  Copyright (c) 2014 juhanapaavola. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"

@implementation TitleScene{
    NSTimer* starTimer;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        label.text = @"MACVADER";
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        label.fontSize=50;
        [self addChild:label];
        
        SKLabelNode* play = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        play.text = @"PRESS SPACE TO PLAY";
        play.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-80);
        play.fontSize=50;
        [self addChild:play];
        
        starTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(addStar:) userInfo:nil repeats:YES];
        [self addStar:nil];
    }
    return self;
}

-(void)keyDown:(NSEvent *)theEvent
{
    [self handleKeyEvent:theEvent keyDown:YES];
}

-(void)handleKeyEvent:(NSEvent*)theEvent keyDown:(BOOL)keyDown
{
    NSString* chars = [theEvent characters];
    NSRange space = [chars rangeOfString:@" "];
    if(space.location!=NSNotFound){
        [starTimer invalidate];
        starTimer = nil;
        GameScene *scene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];
        scene.scaleMode = SKSceneScaleModeAspectFit;
        [self.scene.view presentScene:scene];
    }
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

@end
