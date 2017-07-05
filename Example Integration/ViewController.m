//
//  ViewController.m
//  Example Integration
//
//  Created by Christopher Devereux on 04/07/2017.
//  Copyright © 2017 Redbox Mobile. All rights reserved.
//

#import "ViewController.h"
#import <BlackboxSDK/BlackboxSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)handleTransactionSubmit:(id)sender {
    [[BlackboxSDK sdk] recordRevenue:11.40 withCurrency:BBPCurrencyGBP];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
