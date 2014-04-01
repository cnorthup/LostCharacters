//
//  RootViewController.m
//  LostCharacters
//
//  Created by Charles Northup on 4/1/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSArray* characters;

@end

@implementation RootViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}

@end
