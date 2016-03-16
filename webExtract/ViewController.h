//
//  ViewController.h
//  webExtract
//
//  Created by Nicole on 4/13/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "RecipeBoxTableViewController.h"

@interface ViewController : UIViewController{
    UITextField *saveLocationName;
}
@property (retain, nonatomic) NSURL *urlRecipe;
@property (strong, nonatomic) NSString *saveMode;
@property (strong, nonatomic) NSString *recipeBoxName;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *recipeDB;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

-(NSString *) extractRecipeName: (NSURL *) url;
-(NSString *) extractData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr;
-(NSString *) extractDirectionsData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr;
-(NSString *) extractIngredientsData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr;

@end
