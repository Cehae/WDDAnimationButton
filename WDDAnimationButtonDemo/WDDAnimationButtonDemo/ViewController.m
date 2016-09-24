//
//  ViewController.m
//  WDDAnimationButtonDemo
//
//  Created by WD on 16/9/24.
//  Copyright © 2016年 WD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //autolayout可能会影响动画效果
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
