//
//  ViewController.m
//  rongyunTest
//
//  Created by 陈静 on 14-11-15.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

#import "ViewController.h"
// 引用 IMKit 头文件。
#import "RCIM.h"
// 引用 RCChatViewController 头文件。
#import "RCChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建一个按钮
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.button setFrame:CGRectMake(50, 100, 80, 40)];
    [self.button setTitle:@"Start Chat" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

// 按钮点击事件。
-(IBAction)buttonClicked:(id)sender
{
    // 连接融云服务器。
    [RCIM connectWithToken:@"lnhvVNOYHNY0qN6ALhoDQIzFh9WWzwVLj7zodU/SQOGA4zlJ17NuX83Q+/1Wr4FkXytTnCG0zeMXnsvEbU5yWA==" completion:^(NSString *userId) {
        // 此处处理连接成功。
        NSLog(@"Login successfully with userId: %@.", userId);
        
        // 创建单聊视图控制器。
        RCChatViewController *chatViewController = [[RCIM sharedRCIM]createPrivateChat:@"1" title:@"自问自答" completion:^(){
            // 创建 ViewController 后，调用的 Block，可以用来实现自定义行为。
        }];
        
        // 把单聊视图控制器添加到导航栈。
        [self.navigationController pushViewController:chatViewController animated:YES];
        
    } error:^(RCConnectErrorCode status) {
        // 此处处理连接错误。
        NSLog(@"Login failed.");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end