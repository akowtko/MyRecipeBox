//
//  EnterRecipeViewController.m
//  webExtract
//
//  Created by Nicole on 4/24/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "EnterRecipeViewController.h"

@interface EnterRecipeViewController ()

@end

@implementation EnterRecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    if([_saveMode isEqualToString:@"YES"]){
        [self saveRecipe];
        _saveMode = @"NO";
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                  target:self
                                   action:@selector(saveCell:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    */
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"recipes.db"]];


}
- (IBAction)unwindToEnterRecipeView:(UIStoryboardSegue *)unwindSegue{

}

/*
- (void)saveCell: (id)sender
{
    //have return recipeBoxName
    [self performSegueWithIdentifier:@"enterRecipe" sender:sender];
}
 */
-(void)saveRecipe
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    NSString *name = _recipeName.text;
    NSString *ingredients = _ingredientInput.text;
    NSString *directions = _directionInput.text;
    NSString *yield = _yieldInput.text;
    
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK )
    {
        
        {
            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO RECIPES (recipebox, recipe, ingredients, directions, yield, time) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", _recipeBoxName, name, ingredients, directions, yield, @"9000"];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_recipeDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                UIAlertView *added = [[UIAlertView alloc] initWithTitle:@"Recipe Added" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [added show];
                _recipeName.text = @"";
                _ingredientInput.text = @"Enter ingredients here.";
                _directionInput.text = @"Enter directions here.";
                _yieldInput.text = @"";
            }
            
            else {
                UIAlertView *failAdd = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to add recipe." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [failAdd show];
            }
            sqlite3_finalize(statement);
            sqlite3_close(_recipeDB);
        }
    }

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([_recipeName isFirstResponder] && [touch view] !=
        _recipeName) {
        [_recipeName resignFirstResponder];
    }
    
    else if ([_ingredientInput isFirstResponder] && [touch view] !=
             _ingredientInput) {
        [_ingredientInput resignFirstResponder];
    }
    
    else if ([_directionInput isFirstResponder] && [touch view] !=
             _directionInput) {
        [_directionInput resignFirstResponder];
    }
    
    else if ([_yieldInput isFirstResponder] && [touch view] !=
             _yieldInput) {
        [_yieldInput resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event]; }

#define kOFFSET_FOR_KEYBOARD 166.0

-(void)keyboardWillShow {
    if ([_ingredientInput isFirstResponder] || [_recipeName isFirstResponder]){
        
    }
    // Animate the current view out of the way
    else if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if ([_ingredientInput isFirstResponder] || [_recipeName isFirstResponder]){
        
    }
    else if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:_yieldInput])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
    else{

    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(BOOL)recipeExists{
    //get the recipe name
    NSString *recipeName = _recipeName.text;
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    BOOL answer = NO;
    //open the recipe box name database
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        
        NSString *querySQL = [NSString stringWithFormat: @"SELECT recipe FROM recipes WHERE recipe = \"%@\"", recipeName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                answer = YES;
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(_recipeDB);
    }
    return answer;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"saveButtonBox"])
    {
        BOOL answer = [self recipeExists];
        if(answer){
            UIAlertView *duplicate = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Recipe already exists in database. Each recipe must have a unique name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [duplicate show];
            return NO;
        }
        
        else{
            return YES;
        }
    }
    else{
        return NO;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
