//
//  RecipeViewController.h
//  webExtract
//
//  Created by Nicole on 4/17/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <sqlite3.h>

@interface RecipeViewController : UIViewController
<UITextFieldDelegate>
{
    BOOL editing;
    int verticalOffset;
}
@property (strong, nonatomic) IBOutlet UITextView *ingredientsView;
@property (strong, nonatomic) IBOutlet UITextView *directionsView;
@property (strong, nonatomic) IBOutlet UITextView *recipeEditView;
@property (strong, nonatomic) IBOutlet UILabel *yieldView;
@property (strong, nonatomic) NSString *recipeName;
@property (strong, nonatomic) IBOutlet UITextView *yieldEditView;
@property (strong, nonatomic) IBOutlet UILabel *recipeView;
@property (strong, nonatomic) NSString *yield;
@property (strong, nonatomic) NSString *ingredients;
@property (strong, nonatomic) NSString *directions;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *recipeDB;

@end
