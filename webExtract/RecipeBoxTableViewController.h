//
//  RecipeBoxTableViewController.h
//  webExtract
//
//  Created by Nicole on 4/21/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "ViewController.h"

@interface RecipeBoxTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *recipeBoxNames;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *recipeDB;
@end
