//
//  APViewController.h
//  coreData
//
//  Created by Alan Stirling on 27/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController * resultsController;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
