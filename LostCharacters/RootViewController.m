//
//  RootViewController.m
//  LostCharacters
//
//  Created by Charles Northup on 4/1/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "RootViewController.h"
#import "LostCharacter.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL editing;
}
@property NSArray* characters;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *passengerTextField;
@property (weak, nonatomic) IBOutlet UITextField *actorTextField;


@end

@implementation RootViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    editing = NO;
    [self load];
}

-(void)load{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"LostCharacter"];
    NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"actor" ascending:YES];
    NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    request.sortDescriptors = sortDescriptors;
    NSArray* charactersInDataCore = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (charactersInDataCore.count) {
        self.characters = charactersInDataCore;
    }
    else{
        LostCharacter* initialCharacter1 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter1.actor = @"Mathew Fox";
        initialCharacter1.passenger = @"Jack Shepard";
        LostCharacter* initialCharacter2 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter2.actor = @"Evangline Lilly";
        initialCharacter2.passenger = @"Kate Austen";
        LostCharacter* initialCharacter3 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter3.actor = @"Jorge Garcia";
        initialCharacter3.passenger = @"Hugo “Hurley” Reyes";
        [self.managedObjectContext save:nil];
        self.characters = @[initialCharacter2, initialCharacter3, initialCharacter1];
    }
    [self.myTableView reloadData];
}
- (IBAction)onAddButtonPressed:(id)sender {
    
    LostCharacter* character = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
    character.actor = [self.actorTextField.text capitalizedString];
    character.passenger = [self.passengerTextField.text capitalizedString];
    [self.managedObjectContext save:nil];
    self.actorTextField.text = nil;
    self.passengerTextField.text = nil;
    [self.actorTextField endEditing:YES];
    [self.passengerTextField endEditing:YES];
    [self load];
}
- (IBAction)onEditButtonPressed:(id)sender {
    editing =! editing;
    self.myTableView.editing = editing;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.characters.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LostCharacter* character = self.characters[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LostCharacterCellReuseID"];
    cell.textLabel.text = character.actor;
    return cell;

}

@end
