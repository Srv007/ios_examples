//
//  Singleton.h
//  Singleton
//
//  Created by Duane Cawthron on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

+ (Singleton *)singleton; // Factory always returns the same pointer to the one and only Singleton object

@end
