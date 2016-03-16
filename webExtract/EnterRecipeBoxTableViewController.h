//
//  EnterRecipeBoxTableViewController.h
//  webExtract
//
//  Created by Nicole on 4/21/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "EnterRecipeViewController.h"

@interface EnterRecipeBoxTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *recipeBoxNames;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *recipeDB;
@end
