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

@implementation ViewController{
    Client *client ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    client = [[Client alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doConnect:(id)sender {
    [client start: @"LHN1WRB21X17E1LW45W1"];//@"AAAAAAAAAAAAAAAAAAAF"];//@"1AA8C63C8PSSEKBM111A"];// // Put your device's UID here.
}

- (IBAction)doDisconnect:(id)sender {
    [client Stop];
}

@end
