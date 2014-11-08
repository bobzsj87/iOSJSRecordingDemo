//
//  ViewController.m
//  JSRecordingDemo
//
//  Created by Bob Zhou on 2014-11-04.
//  Copyright (c) 2014 Bob Zhou. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    theWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    theWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    theWebView.delegate = self;
    [self.view addSubview:theWebView];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [theWebView loadRequest:request];
    
    [JSAudioRecorder sharedInstance].linkedWebview = theWebView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return [[JSAudioRecorder sharedInstance] parseURL:request.URL];
}


@end
