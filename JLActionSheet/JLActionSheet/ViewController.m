//
//  ViewController.m
//  JLActionSheet
//
//  Created by shijialong on 2016/11/30.
//  Copyright © 2016年 shijialong. All rights reserved.
//

#import "ViewController.h"
#import "JLActionSheet.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)buttonAction:(UIButton *)sender {
    [JLActionSheet showActionSheetViewWithTitle:@"actionSheet."
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:@[@"0", @"1", @"2"]
                                  selectSheetBlock:^(JLActionSheet *actionSheetView, NSInteger actionIndex) {
                                      NSLog(@"%zd", actionIndex);
                                  }];
}




@end
