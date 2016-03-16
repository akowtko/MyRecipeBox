//
//  recipeGroupCollectionViewController.m
//  webExtract
//
//  Created by Nicole on 4/19/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "recipeGroupCollectionViewController.h"

@interface recipeGroupCollectionViewController (){
}
//@property (nonatomic, weak) IBOutlet recipeViewLayout *recipeLayout;
@end

@implementation recipeGroupCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    deleteMode = NO;
    editMode = NO;
    
    //Add Recipe Box button on right side
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addCell)];
    
    //Edit recipe box button on left side
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                      target:self
                                      action:@selector(deleteWarning)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = editButton;
    
    //Initialize data arrays.
    _recipeBoxImageTypes = [@[@"TealRecipe.png",@"GreenRecipe.png",@"BlueRecipe.png",@"RedRecipe.png",@"PurpleRecipe.png"]mutableCopy];
    NSString *docsDir;
    NSArray *dirPaths;
    _recipeBoxTitles = [[NSMutableArray alloc] init];
    _recipeBoxImages = [[NSMutableArray alloc] init];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"recipes.db"]];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //open the recipe box name database
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT name FROM boxnames";
        NSString *querySQL2 = @"SELECT image FROM boxnames";
        const char *query_stmt = [querySQL UTF8String];
        const char *query_stmt2 = [querySQL2 UTF8String];
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *boxName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                [_recipeBoxTitles addObject: boxName];
            }
            
            sqlite3_finalize(statement);
        }
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt2, -1, &statement, NULL) == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *boxImage = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                [_recipeBoxImages addObject: boxImage];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(_recipeDB);
    }
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bookshelf.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Prevents going to detail view if the user is attempting to edit or delete a recipe box
 - (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
     if(deleteMode == YES || editMode == YES){
         return NO;
     }
    else{
        return YES;
    }
 }


#pragma mark - Add Cell

-(void)addCell{
    UIAlertView *addPopUp = [[UIAlertView alloc] initWithTitle:@"New Box Title" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
    addPopUp.alertViewStyle = UIAlertViewStylePlainTextInput;
    recipeBoxNameInput = [addPopUp textFieldAtIndex:0];
    recipeBoxNameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    recipeBoxNameInput.keyboardAppearance = UIKeyboardAppearanceAlert;
    [addPopUp show];
}

-(id)randomObject:(NSMutableArray *)array{
    if([array count] == 0){
        return nil;
    }
    else{
        return [array objectAtIndex:arc4random() %[array count]];
    }
}

#pragma mark
#pragma mark Edit/Delete Cell

//Declares actions to be taken if user presses recipe box in edit or delete mode
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(deleteMode == YES){
        NSArray *defaultRecipeBox  = [[NSArray alloc] initWithObjects:@"Entree",@"Appetizer",@"Dessert", nil];
        long currentRow = [indexPath row];
        if([defaultRecipeBox containsObject:_recipeBoxTitles[currentRow]]){
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Default recipe boxes cannot be deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [error show];
        }
        
        else{
            UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Delete Box" message:@"Are you sure you want to delete the recipe box and all the recipes inside?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirm show];
            deleteRow = currentRow;
            deletePath = indexPath;
        }
        
        deleteMode = NO;
    }

    //Allows user to input new recipe box name in a UIAlertView
    else if(editMode == YES){
        editMode = NO;
        editRow = [indexPath row];
        editPath = indexPath;
        [self editPopUp];
    }
    
}

//Determines whether user is in edit or delete mode
-(void)deleteWarning{
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Select Mode" message:@"Press edit to change the name of the recipe box. Press delete and you will enter deletion mode. The next recipe box you select will be deleted along with all the recipes inside. Or press cancel to neither edit or delete." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Edit", @"Delete", nil];
    [warning show];
}

//AlertView for user to enter the new name of the recipe box.
-(void)editPopUp{
    UIAlertView *editView = [[UIAlertView alloc] initWithTitle:@"New Box Name" message:@"Enter the new recipe box name." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Update", nil];
    editView.alertViewStyle = UIAlertViewStylePlainTextInput;
    recipeBoxNameEdit = [editView textFieldAtIndex:0];
    recipeBoxNameEdit.clearButtonMode = UITextFieldViewModeWhileEditing;
    recipeBoxNameEdit.keyboardAppearance = UIKeyboardAppearanceAlert;
    [editView show];
}

#pragma mark - Any Cell
//Checks which button was pressed in any UIAlertView and responds accordingly
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex: buttonIndex];
    
    //Add Recipe Box
    if([buttonTitle isEqualToString:@"Ok"]){
        //Sets recipe box name to user input
        recipeBoxName = recipeBoxNameInput.text;
        NSArray *newData = [[NSArray alloc] initWithObjects:recipeBoxName, nil];
        [self.collectionView performBatchUpdates:^{
            [self.recipeBoxTitles addObjectsFromArray:newData];
            //***randomly generate color
            _randomColor = [self randomObject:self.recipeBoxImageTypes];
            [self.recipeBoxImages addObject:_randomColor];
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:[self.recipeBoxTitles count] - 1 inSection:0]];
            [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
        }
                                      completion: nil];
        const char *dbpath = [_databasePath UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK )
        {
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO BOXNAMES (name, image) VALUES (\"%@\", \"%@\")", recipeBoxName, _randomColor];
                
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(_recipeDB, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE) {
                }
                sqlite3_finalize(statement);
                sqlite3_close(_recipeDB);
            }
            
        }
        
    }
    
    //Puts user into delete mode so they will delete next box pressed
    else if([buttonTitle isEqualToString:@"Delete"]){
        deleteMode = YES;
    }
    
    //Add edit method
    else if([buttonTitle isEqualToString:@"Edit"]){
        editMode = YES;
        
    }
    
    //Means user has confirmed deleting the selected box, proceeds with delete
    else if([buttonTitle isEqualToString:@"Yes"]){
        const char *dbpath = [_databasePath UTF8String];
        sqlite3_stmt *statement;
        
        //open the recipe box name database
        if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM recipes WHERE recipebox = \"%@\"", _recipeBoxTitles[deleteRow]];
            const char *query_stmt = [querySQL UTF8String];
            
            if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
                if(sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"Deleted recipes");
                }
                else{
                    NSLog(@"Did not delete recipe");
                }
                
                sqlite3_finalize(statement);
            }
            sqlite3_close(_recipeDB);
        }
        [self deleteRecipeBox:_recipeBoxTitles[deleteRow]];
        [_recipeBoxTitles removeObjectAtIndex: deleteRow];
        
        NSArray *deletions = @[deletePath];
        [self.collectionView deleteItemsAtIndexPaths:deletions];
    }
    
    //User has submitted text to update the recipe box name
    else if([buttonTitle isEqualToString:@"Update"]){
        recipeBoxNameUpdate = recipeBoxNameEdit.text;
        NSString *originalName = _recipeBoxTitles[editRow];
        [self.recipeBoxTitles replaceObjectAtIndex:editRow withObject:recipeBoxNameUpdate];
        [self.collectionView reloadItemsAtIndexPaths: [[NSArray alloc] initWithObjects: editPath, nil]];
        const char *dbpath = [_databasePath UTF8String];
        sqlite3_stmt *statement;
        if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
        {
            NSString *updateSQL = [NSString stringWithFormat: @"UPDATE boxnames SET name = \"%@\" WHERE name = \"%@\"", recipeBoxNameUpdate, originalName];
            const char *update_stmt = [updateSQL UTF8String];
            sqlite3_prepare_v2(_recipeDB, update_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Update finished");
            }
            else {
                NSLog(@"Failed to update");
            }
            sqlite3_finalize(statement);
            sqlite3_close(_recipeDB);
        }
        
    }
    
}
-(void)deleteRecipeBox: (NSString *) boxNameDelete{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    //open the recipe box name database
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM BOXNAMES WHERE name = \"%@\"", boxNameDelete];
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"Deleted recipebox from database");
            }
            else{
                NSLog(@"Error deleting recipebox");
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(_recipeDB);
    }

}

#pragma mark -
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _recipeBoxTitles.count;
}

//Sets up recipe box cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    recipeGroupCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"recipeGroupCell" forIndexPath:indexPath];
    UIImage *image;
    NSString *title;
    long row = [indexPath row];
    image = [UIImage imageNamed:_recipeBoxImages[row]];
    title = _recipeBoxTitles[row];
    myCell.recipeBoxImage.image = image;
    myCell.boxTitle.text = title;
    return myCell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"recipeListSegue"]) {
        RecipeListTableViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *myIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex: 0];
        long row = [myIndexPath row];
        detailViewController.recipeBoxName  = _recipeBoxTitles[row];
    }
    
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

 
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(4,4,0,4);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    return 14.0;
}
@end

//adding cell if you select the "Add cell" button
/*
 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
 {
 if (indexPath.row == _recipeBoxTitles.count)
 {
 if(!cancelResult){
 NSArray *newData = [[NSArray alloc] initWithObjects:recipeBoxName, nil];
 [self.collectionView performBatchUpdates:^{
 [self.recipeBoxTitles addObjectsFromArray:newData];
 [self.recipeBoxImages addObject:@"TealRecipe.png"];
 NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
 [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:[self.recipeBoxTitles count] - 1 inSection:0]];
 [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
 }
 completion: nil];
 }
 }
 }
 */

/*
 - (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
 UICollectionViewCell *cell = (UICollectionViewCell*) sender;
 NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
 if(indexPath.row == _recipeBoxTitles.count){
 return NO;
 }
 else{
 return YES;
 }
 }
 */


 

