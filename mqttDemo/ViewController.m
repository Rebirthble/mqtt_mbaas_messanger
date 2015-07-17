//
//  ViewController.m
//  mqttDemo
//
//  Created by SCI01433 on 2015/06/24.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "ViewController.h"
#import "MessengerViewController.h"

@interface ViewController ()


- (IBAction)pushButtonStart:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *displayName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MessengerView"]) {
        MessengerViewController *messengerVC = [segue destinationViewController];
        messengerVC.senderDisplayName = self.displayName.text;
    }
}

- (IBAction)pushButtonStart:(id)sender {
    
    //MessengerViewへの画面遷移を行う
    [self performSegueWithIdentifier:@"MessengerView" sender:self];
}

@end
