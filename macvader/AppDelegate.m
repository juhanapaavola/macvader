//
//  AppDelegate.m
//  macvader
//
//  Created by juhana on 25/06/14.
//  Copyright (c) 2014 juhanapaavola. All rights reserved.
//

#import "AppDelegate.h"
#import "TitleScene.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SKScene *scene = [TitleScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [self.skView presentScene:scene transition:[SKTransition moveInWithDirection:SKTransitionDirectionUp duration:5.0]];
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
