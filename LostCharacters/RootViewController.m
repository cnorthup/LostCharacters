//
//  RootViewController.m
//  LostCharacters
//
//  Created by Charles Northup on 4/1/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "RootViewController.h"
#import "LostCharacter.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    BOOL editing;
    NSNumber* aliveOrDead;
}
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property NSMutableArray* characters;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *passengerTextField;
@property (weak, nonatomic) IBOutlet UITextField *actorTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property NSMutableArray* filtered;
@property NSString* searchQuery;



@end

@implementation RootViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    aliveOrDead = [NSNumber numberWithInt:1];
    editing = NO;
    [self load];
    self.toolBar.hidden =! editing;
    self.bottomToolBar.hidden =! editing;
    self.addButton.enabled = NO;
    self.filtered = [NSMutableArray new];
}

-(void)load{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"LostCharacter"];
    NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"actor" ascending:YES];
    NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(passenger CONTAINS[c] %@) OR (actor CONTAINS[c] %@)", self.searchQuery, self.searchQuery];
//    [request setPredicate:predicate];
//    NSLog(@"%@", request.predicate);
    request.sortDescriptors = sortDescriptors;
    NSArray* charactersInDataCore = [self.managedObjectContext executeFetchRequest:request error:nil];
    if (charactersInDataCore.count) {
        self.characters = (NSMutableArray*)charactersInDataCore;
    }
    else{
        LostCharacter* initialCharacter1 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter1.actor = @"Mathew Fox";
        initialCharacter1.passenger = @"Jack Shepard";
        initialCharacter1.dead = 0;
        LostCharacter* initialCharacter2 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter2.actor = @"Evangline Lilly";
        initialCharacter2.passenger = @"Kate Austen";
        initialCharacter2.dead = 0;
        LostCharacter* initialCharacter3 = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
        initialCharacter3.actor = @"Jorge Garcia";
        initialCharacter3.passenger = @"Hugo “Hurley” Reyes";
        initialCharacter3.dead = 0;
        [self.managedObjectContext save:nil];
        self.characters = [NSMutableArray arrayWithObjects:initialCharacter2, initialCharacter3, initialCharacter1, nil];
    }
    [self.myTableView reloadData];
}
- (IBAction)onAddButtonPressed:(id)sender {
    
    LostCharacter* character = [NSEntityDescription insertNewObjectForEntityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
    character.actor = [self.actorTextField.text capitalizedString];
    character.passenger = [self.passengerTextField.text capitalizedString];
    character.dead = aliveOrDead;
    [self.managedObjectContext save:nil];
    self.actorTextField.text = nil;
    self.passengerTextField.text = nil;
    [self.actorTextField endEditing:YES];
    [self.passengerTextField endEditing:YES];
    [self load];
}
- (IBAction)aliveOrDeadSwitch:(UISwitch*)sender {
    aliveOrDead = [NSNumber numberWithBool:sender.on];
    NSLog(@"%@", aliveOrDead);
}

- (IBAction)onEditButtonPressed:(id)sender {
    editing =! editing;
    if (editing) {
        float width = self.myTableView.frame.size.width;
        self.myTableView.frame = CGRectMake(0, 152, width, self.myTableView.frame.size.height+44);
    }else{
        float width = self.myTableView.frame.size.width;
        self.myTableView.frame = CGRectMake(0, 108, width, self.myTableView.frame.size.height-44);
    }
    self.myTableView.editing = editing;
    self.toolBar.hidden =! editing;
    self.bottomToolBar.hidden =!editing;
    self.addButton.enabled = editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:self.characters[indexPath.row]];
        [self.managedObjectContext save:nil];
        [self load];
        [self.myTableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.characters.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Smoke Monster";
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LostCharacter* character = self.characters[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LostCharacterCellReuseID"];
    NSString* dead;
    if (character.dead == 0) {
        dead = @"Dead";
    }
    else{
        dead = @"Alive";
    }
    if ([character.passenger isEqualToString:@""]) {
        cell.textLabel.text = @"One of the Others?????";
        
    }
    else{
        NSString* nameAndStatus = [NSString stringWithFormat:@"%@: %@",character.passenger, dead];
        cell.textLabel.text = nameAndStatus;
        
    }
    if ([character.actor isEqualToString:@""]) {
        cell.detailTextLabel.text = @"No audtion set";
        
    }
    else{
        cell.detailTextLabel.text = character.actor;
        
    }
    return cell;

}

-(void)filter:(NSString *)searchedTextData //filter method helper
{
    NSMutableArray *filteredTableData = [[NSMutableArray alloc] init];
    
    // Create our fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Define the entity we are looking for
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LostCharacter" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    // Define how we want our entities to be sorted
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"passenger" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // If we are searching for anything...
    if(searchedTextData.length > 0)
    {
        // Define how we want our entities to be filtered
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(passenger CONTAINS[c] %@) OR (actor CONTAINS[c] %@)", searchedTextData, searchedTextData];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    
    // Finally, perform the load
    NSArray *loadedEntities = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    filteredTableData = [[NSMutableArray alloc] initWithArray:loadedEntities];
    
    self.characters = filteredTableData;
    
    NSLog(@"Filtered Data -->, %@", filteredTableData);
    NSLog(@"Text Search->, %@", searchedTextData);
    
    //[self load];
    [self.myTableView reloadData];
    
    
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (![searchText isEqualToString:@""]) {
        [self filter:searchText];
    }
    else{
    [self load];
    }
}

@end
