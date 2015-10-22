//
//  ViewController.m
//  MySee
//
//  Created by ml  on 14/11/2.
//  Copyright (c) 2014年 ml . All rights reserved.
//

#import "ViewController.h"
#import "Client.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Client *client = [[Client alloc] init];
    [client start:@"LHN1WRB21X17E1LW45W1"]; // Put your device's UID here.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
