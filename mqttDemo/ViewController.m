//
//  ViewController.m
//  mqttDemo
//
//  Created by SCI01433 on 2015/06/24.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "ViewController.h"
#import "MessangerViewController.h"

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
    if ([[segue identifier] isEqualToString:@"MessangerView"]) {
        MessangerViewController *messangerVC = [segue destinationViewController];
        messangerVC.senderDisplayName = self.displayName.text;
    }
}

- (IBAction)pushButtonStart:(id)sender {
    
    //MessangerViewへの画面遷移を行う
    [self performSegueWithIdentifier:@"MessangerView" sender:self];
}

@end
