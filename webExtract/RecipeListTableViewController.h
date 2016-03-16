//
//  RecipeListTableViewController.h
//  webExtract
//
//  Created by Nicole on 4/22/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeViewController.h"
#import "RecipeListTableViewCell.h"

@interface RecipeListTableViewController : UITableViewController
@property (strong, nonatomic) NSString *recipeBoxName;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic, strong) NSMutableArray *recipeNames;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (nonatomic) sqlite3 *recipeDB;
@end
