//
//  Person.m
//  coreData
//
//  Created by Alan Stirling on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic first_name;
@dynamic last_name;
@dynamic email;
@dynamic date_of_birth;

-(NSString *) details{
    return [NSString stringWithFormat:@"%@ %@ - %@", self.first_name, self.last_name, self.email];
}

@end
