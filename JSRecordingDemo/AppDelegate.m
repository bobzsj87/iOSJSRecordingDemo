//
//  AppDelegate.m
//  JSRecordingDemo
//
//  Created by Bob Zhou on 2014-11-04.
//  Copyright (c) 2014 Bob Zhou. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    
    return YES;
}



@end
