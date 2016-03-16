//
//  recipeGroupCollectionViewController.h
//  webExtract
//
//  Created by Nicole on 4/19/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "recipeGroupCell.h"
#import <sqlite3.h>
#import "RecipeListTableViewController.h"

@interface recipeGroupCollectionViewController : UICollectionViewController
<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSString *recipeBoxName;
    NSString *recipeBoxNameUpdate;
    UITextField *recipeBoxNameInput;
    UITextField *recipeBoxNameEdit;
    
    BOOL deleteMode;
    BOOL editMode;
    //will save the row and indexpath for deletion measures
    long deleteRow;
    long editRow;
    NSIndexPath *editPath;
    NSIndexPath *deletePath;
}
@property (strong, nonatomic) NSMutableArray *recipeBoxImages;
@property (strong, nonatomic) NSMutableArray *recipeBoxImageTypes;
@property (strong, nonatomic) NSMutableArray *recipeBoxTitles;
@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *randomColor;
@property (nonatomic) sqlite3 *recipeDB;
@end
