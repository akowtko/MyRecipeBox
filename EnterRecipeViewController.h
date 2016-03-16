//
//  EnterRecipeViewController.h
//  webExtract
//
//  Created by Nicole on 4/24/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnterRecipeBoxTableViewController.h"
#import <sqlite3.h>

@interface EnterRecipeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *recipeName;
@property (strong, nonatomic) IBOutlet UITextView *ingredientInput;
@property (strong, nonatomic) IBOutlet UITextView *directionInput;
@property (strong, nonatomic) IBOutlet UITextField *yieldInput;
@property (strong, nonatomic) NSString *recipeBoxName;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *recipeDB;
@property (strong, nonatomic) NSString *saveMode;


@end
