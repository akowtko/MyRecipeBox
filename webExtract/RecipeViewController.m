//
//  RecipeViewController.m
//  webExtract
//
//  Created by Nicole on 4/17/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "RecipeViewController.h"

@interface RecipeViewController ()

@end

@implementation RecipeViewController


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
    editing = NO;
    UIBarButtonItem *editButton = self.editButtonItem;
    //self.navigationItem.leftBarButtonItem.style = UIBarButtonSystemItemEdit;
    [editButton setTarget: self];
    [editButton setAction:@selector(toggleEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"recipes.db"]];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //open the recipe box name database
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT yield, time, ingredients, directions FROM recipes WHERE recipe = \"%@\"", _recipeName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                _yield = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                _yieldView.text = _yield;
                
                _time = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                
                _ingredients = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                _ingredientsView.text = _ingredients;
                
                _directions = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                _directionsView.text = _directions;
                
                _recipeView.text = _recipeName;
            
                NSLog(@"Match found");
            }
            
            else
            {
                NSLog(@"Match not found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_recipeDB);
    }
}

-(IBAction)toggleEdit{
    if (editing){
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit", @"Edit");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemDone;
        [self editRecipe];
        _recipeEditView.backgroundColor = [UIColor clearColor];
        _recipeEditView.text = @"";
        _yieldEditView.backgroundColor = [UIColor clearColor];
        _yieldEditView.text = @"";
        editing = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemEdit;
        editing = YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    //return yes if the edit button was clicked
    if(editing){
        textView.backgroundColor = [UIColor whiteColor];
        return YES;
    }
    else{
        return NO;
    }
}

-(void)editRecipe{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    NSString *newRecipeName;
    NSString *newYield;
    //This makes sure that if the user just clicked to edit and didn't type anything, the recipe name isn't cleared
    if([_recipeEditView.text isEqualToString: @""]){
        newRecipeName = _recipeName;
    }
    else{
        newRecipeName = _recipeEditView.text;
        NSLog(@"%@",_recipeEditView.text);
    }
    
    if([_yieldEditView.text isEqualToString: @""]){
        newYield = _yield;
    }
    else{
        newYield = _yieldEditView.text;
    }
    
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE recipes SET recipe = \"%@\", ingredients = \"%@\", directions = \"%@\", yield = \"%@\" WHERE recipe = \"%@\"", newRecipeName, _ingredientsView.text, _directionsView.text, newYield, _recipeName];
        
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(_recipeDB, update_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            _recipeView.text = newRecipeName;
            _yieldView.text = newYield;
            NSLog(@"It worked!");
        }
        else {
            NSLog(@"Failed to update recipe");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_recipeDB);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([_ingredientsView isFirstResponder] && [touch view] !=
        _ingredientsView) {
        [_ingredientsView resignFirstResponder];
    }
    
    else if ([_directionsView isFirstResponder] && [touch view] !=
        _directionsView) {
        [_directionsView resignFirstResponder];
    }
    
    else if ([_yieldEditView isFirstResponder] && [touch view] !=
        _yieldEditView) {
        [_yieldEditView resignFirstResponder];
    }
    
    else if ([_recipeEditView isFirstResponder] && [touch view] !=
        _recipeEditView) {
        [_recipeEditView resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event]; }

#define kOFFSET_FOR_KEYBOARD 166.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if ([_ingredientsView isFirstResponder] || [_recipeEditView isFirstResponder]){

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

-(void)keyboardWillHide {
    if ([_ingredientsView isFirstResponder] || [_recipeEditView isFirstResponder]){
        
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
