//
//  APViewController.m
//  coreData
//
//  Created by Alan Stirling on 27/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APViewController.h"
#import "APAppDelegate.h"
#import "Content.h"
#import "Person.h"

@interface APViewController ()

- (void) getFeed;

@end


@implementation APViewController

@synthesize resultsController = _resultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize contentLabel = _contentLabel;
@synthesize peopleList = _peopleList;


-(void) getFeed
{
    NSError * e = nil;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://feeds.astirling.com/people.json"]];
    NSDictionary * feed = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &e];
    
    if(!feed){
        NSLog(@"Error - %@", e);
    }
    else {
        for(id entry in feed){
            Person * newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
            
            newPerson.first_name = [entry valueForKey:@"first_name"];
            newPerson.last_name = [entry valueForKey:@"last_name"];
            newPerson.email = [entry valueForKey:@"email"];
            NSDateFormatter * df = [NSDateFormatter new];
            df.TimeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            newPerson.date_of_birth = [df dateFromString:[entry valueForKey:@"date_of_birth"]];
            

            if(![self.managedObjectContext save:&e]){
                NSLog(@"Error - %@, %@", e, [e userInfo]);
            }else {
                NSLog(@"Person - %@", newPerson);
            }

        }
    }
}

- (void)viewDidLoad
{
    //get managed object context from APAppDelegate
    self.managedObjectContext = ((APAppDelegate *)UIApplication.sharedApplication.delegate).managedObjectContext;
    
    [self getFeed];
    
    if(self.resultsController.sections.count > 0 && [[self.resultsController.sections objectAtIndex:0] numberOfObjects] > 0){
        
        NSLog(@"%d", self.resultsController.sections.count);
    
        // set the contents of the label to the body of the object from the resultsController at index 0 (the first object)
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        self.contentLabel.text = ((Person *)[self.resultsController objectAtIndexPath:indexPath]).details;
        
        [super viewDidLoad];
    }
}

- (void)viewDidUnload
{
    [self setContentLabel:nil];
    [self setPeopleList:nil];
    [super viewDidUnload];
    
    self.resultsController = nil; // set results controller to nil
}



// override getter for resultsController
-(NSFetchedResultsController *) resultsController
{
    if(_resultsController == nil)
    {
        NSFetchRequest * request = [NSFetchRequest new]; // fetch request, new same as "alloc] init]"
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        
        request.entity = entity; // set entity to get
        
        NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:TRUE]; // sort description
        
        [request setSortDescriptors:[NSArray arrayWithObject:sort]]; // set sort for fetch
        
        request.fetchBatchSize = 10; // set number of records to get
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"]; // initialize the resultsController
        _resultsController.delegate = self;
        
        
        // perform fetch and catch errors
        NSError * error = nil;
        if(![_resultsController performFetch:&error]){
            NSLog(@"Error - %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    

    /*
    // this section is just to populate the the results controller if it is empty
    if([_resultsController.fetchedObjects count] < 1){
        
        NSEntityDescription * entity = [[_resultsController fetchRequest] entity];
        
        Content * newContent = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
        
        newContent.body = @"Test Content";
        
        NSError * error;
        if(![self.managedObjectContext save:&error]){
            NSLog(@"Error - %@, %@", error, [error userInfo]);
        }
        
        // perform fetch and catch errors
        if(![_resultsController performFetch:&error]){
            NSLog(@"Error - %@, %@", error, [error userInfo]);
            abort();
        }
    }
    //---------------------------------------------------------------------------
    */

    return _resultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.resultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.resultsController.sections objectAtIndex:section] numberOfObjects];
}

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    Person * newPerson = [self.resultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = newPerson.details;
//}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = ((Person *)[self.resultsController objectAtIndexPath:indexPath]).details;
    return cell;
}

@end
