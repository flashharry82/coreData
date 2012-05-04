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


-(void) getFeed
{
    //NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://feed.astirling.com/feed.json"]];
    NSError * e = nil;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://feed.astirling.com/feed.json"]];
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
            newPerson.date_of_birth = (NSDate *)[entry valueForKey:@"date_of_birth"];
        }
    }
}

- (void)viewDidLoad
{
    //get managed object context from APAppDelegate
    self.managedObjectContext = ((APAppDelegate *)UIApplication.sharedApplication.delegate).managedObjectContext;
    

    // set the contents of the label to the body of the object from the resultsController at index 0 (the first object)
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.contentLabel.text = ((Content *)[self.resultsController objectAtIndexPath:indexPath]).body;
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setContentLabel:nil];
    [super viewDidUnload];
    
    self.resultsController = nil; // set results controller to nil
}



// override getter for resultsController
-(NSFetchedResultsController *) resultsController
{
    if(_resultsController == nil)
    {
        NSFetchRequest * request = [NSFetchRequest new]; // fetch request, new same as "alloc] init]"
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
        
        request.entity = entity; // set entity to get
        
        NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"body" ascending:FALSE]; // sort description
        
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


@end
