//
//  ViewController.m
//  Rocksauce
//
//  Created by Gina Mullins on 4/4/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"

@interface ViewController ()

@property (nonatomic, strong) HomeViewController *homeView;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // load a new view for effects
    if (self.homeView == nil)
    {
        self.homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    
    // add a transtion to fade in
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:self.homeView animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
