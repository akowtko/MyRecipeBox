//
//  ViewController.m
//  webExtract
//
//  Created by Nicole on 4/13/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end
@implementation ViewController
@synthesize urlRecipe;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the allrecipes main page
    NSURL *defaultURL = [NSURL URLWithString:@"http://www.allrecipes.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL: defaultURL];
    [self.webView loadRequest:request];
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"recipes.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //This creates the recipe database if it does not already exist
    if ([filemgr fileExistsAtPath: _databasePath ] == NO) {
        //converting path to UTF-8
        const char *dbpath = [_databasePath UTF8String];
        
        //creates database
        if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt_recipes = "CREATE TABLE IF NOT EXISTS RECIPES (ID INTEGER PRIMARY KEY AUTOINCREMENT, RECIPEBOX TEXT, RECIPE TEXT, INGREDIENTS TEXT, DIRECTIONS TEXT, YIELD TEXT, TIME TEXT)";
            
            const char *sql_stmt_boxnames = "CREATE TABLE IF NOT EXISTS BOXNAMES (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, IMAGE TEXT)";
            
            if (sqlite3_exec(_recipeDB, sql_stmt_recipes, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _errorLabel.text = @"Failed to create recipes table";
            }
            
            if (sqlite3_exec(_recipeDB, sql_stmt_boxnames, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _errorLabel.text = @"Failed to create boxnames table";
            }
            //saving the three default recipe boxes in the database
            [self saveRecipeBoxNames:@"Entree" andImage:@"BlueRecipe.png"];
            [self saveRecipeBoxNames:@"Appetizer" andImage:@"GreenRecipe.png"];
            [self saveRecipeBoxNames:@"Dessert" andImage:@"PurpleRecipe.png"];
            
            sqlite3_close(_recipeDB);
        }
        
        else{
            _errorLabel.text = @"Failed to open/create database";
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if([_saveMode isEqualToString:@"YES"])
    {
        urlRecipe = _webView.request.mainDocumentURL;
        [self saveRecipeDatabase];
    }
}
- (IBAction)unwindToView:(UIStoryboardSegue *)unwindSegue{
    
}


-(void)saveRecipeDatabase{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    //get the recipe name
    NSString *recipeName = [self extractRecipeName: urlRecipe];
    
    //get the ingredients
    NSString *ingredients = [self extractIngredientsData:urlRecipe recipeName:recipeName leftString:@"data-nameid=" rightString:@"</span>"];
    
    //get the directions
    NSString *directions = [self extractDirectionsData:urlRecipe recipeName:recipeName leftString:@"<li><span>" rightString:@"</span></li>"];
    
    //get the yield
    NSString *yield = [self extractData:urlRecipe recipeName:recipeName leftString:@"originalYield\">" rightString:@"</span>"];
    yield = [yield stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK )
    {
        if(recipeName != nil)
        {
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO RECIPES (recipebox, recipe, ingredients, directions, yield, time) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", _recipeBoxName, recipeName, ingredients, directions, yield, @"9000"];
                
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(_recipeDB, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE) {
                    _errorLabel.text = @"Recipe added";
                }
                
                else {
                    _errorLabel.text = @"Failed to add recipe";
                }
                sqlite3_finalize(statement);
                sqlite3_close(_recipeDB);
            }
            _saveMode = @"NO";
            
        }
        
        else
        {
            _errorLabel.text = @"Error: Did not select a recipe on AllRecipes.com";
        }
    }
}

-(BOOL)recipeExists{
    urlRecipe = _webView.request.mainDocumentURL;
    //get the recipe name
    NSString *recipeName = [self extractRecipeName: urlRecipe];
    
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

//saves recipe box names and images to the database
-(void)saveRecipeBoxNames:(NSString *)boxName andImage: (NSString *)boxImage
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO BOXNAMES (name, image) VALUES (\"%@\",\"%@\")", boxName, boxImage];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_recipeDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            _errorLabel.text = @"Recipe Box added";
        }
        
        else {
            _errorLabel.text = @"Failed to add recipe box";
        }
        sqlite3_finalize(statement);
        sqlite3_close(_recipeDB);
    }
}

#pragma mark
#pragma mark Data Extraction Functions
//Outputs a string containing all of the info you were searching for, with each entry separated by a line break.
-(NSString *) extractData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr
{
    NSString *extractText = @"";
    NSString *foundData = @"";
    
    //Extracts the data from the webpage, and turns it into an NSString
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    

    NSScanner *scanner = [NSScanner scannerWithString:pageSource];
    //loop through the html data
    while(![scanner isAtEnd]){
        NSInteger leftPos, rightPos;
        
        [scanner scanUpToString:leftStr intoString:nil];
        leftPos = [scanner scanLocation];
        
        if(![scanner scanUpToString:rightStr intoString:nil]){
            break;
        }
        rightPos = [scanner scanLocation] + 1;
        
        //remember counting starts at 0, so if the word is 3 long, leftPos += 2
        leftPos += [leftStr length];
        foundData = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 1)];
        extractText = [extractText stringByAppendingString: [NSString stringWithFormat:@"\n%@",foundData]];
    }
    return extractText;
}

-(NSString *) extractDirectionsData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr
{
    NSString *extractText = @"";
    NSString *foundData = @"";
    int i = 1;
    //Extracts the data from the webpage, and turns it into an NSString
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSScanner *scanner = [NSScanner scannerWithString:pageSource];
    NSScanner *endScanner = [NSScanner scannerWithString:pageSource];
    
    NSInteger leftPos, rightPos, endPos;
    
    //scan to find the Directions title
    [scanner scanUpToString:@"<h2>Directions" intoString:nil];
    
    //scanning to find where I want to break out of the while loop below
    [endScanner scanUpToString:@"<h2>Directions" intoString:nil];
    [endScanner scanUpToString:@"</ol>" intoString:nil];
    endPos = [endScanner scanLocation];
    
    //loop through the html data after the Directions title point
    while([scanner scanLocation] < endPos){
        [scanner scanUpToString:leftStr intoString:nil];
        leftPos = [scanner scanLocation];
        
        if(![scanner scanUpToString:rightStr intoString:nil]){
            break;
        }
        rightPos = [scanner scanLocation] + 1;
        
        //remember counting starts at 0, so if the word is 3 long, leftPos += 2
        leftPos += [leftStr length];
        if([scanner scanLocation] > endPos){
            break;
        }
        else{
            foundData = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 1)];
            extractText = [extractText stringByAppendingString: [NSString stringWithFormat:@"%i. %@\n\n",i,foundData]];
            i ++;
        }
    }
    return extractText;
}

-(NSString *) extractIngredientsData: (NSURL *) url recipeName:(NSString *)name leftString:(NSString *)leftStr rightString:(NSString *)rightStr
{
    NSString *extractText = @"";
    NSString *foundData = @"";
    
    //Extracts the data from the webpage, and turns it into an NSString
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSScanner *scanner = [NSScanner scannerWithString:pageSource];
    
    NSInteger leftPos, rightPos;
    
    
    //loop through the html data
    while(![scanner isAtEnd]){
        [scanner scanUpToString:leftStr intoString:nil];
        [scanner scanUpToString:@">" intoString:nil];
        leftPos = [scanner scanLocation];
        
        if(![scanner scanUpToString:rightStr intoString:nil]){
            break;
        }
        rightPos = [scanner scanLocation] + 1;
        
        //remember counting starts at 0, so if the word is 3 long, leftPos += 2
        leftPos += 1;
        foundData = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 1)];
        extractText = [extractText stringByAppendingString: [NSString stringWithFormat:@"%C%@\n",0x2022,foundData]];
        
    }
    return extractText;
}


//Extracts the name of a recipe
-(NSString *) extractRecipeName: (NSURL *) url
{
    NSString *extractText = @"";
    
    //Extracts the data from the webpage, and turns it into an NSString
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSScanner *recipeScanner = [NSScanner scannerWithString:pageSource];
    
    NSInteger leftPos, rightPos;
    //this is for the non-mobile page
    //[scanner scanUpToString:@"title\" content=\"" intoString:nil];
    
    NSString *leftPosStr = @"\"recipe-details-right clearfix\">";
    [recipeScanner scanUpToString: leftPosStr intoString:nil];
    leftPos = [recipeScanner scanLocation];
    
    //non-mobile page
    //[scanner scanUpToString:@"\"></meta>" intoString:nil];
    [recipeScanner scanUpToString:@"</h1>" intoString:nil];
    
    rightPos = [recipeScanner scanLocation] + 1;
        
    //remember counting starts at 0, so if the word is 3 long, leftPos += 2
    leftPos += ([leftPosStr length] + 22);
    extractText = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 1)];
    
        return extractText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"chooseBox"])
    {
        BOOL answer = [self recipeExists];
        if(answer){
            _errorLabel.text = @"Recipe already exists in database";
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
@end

/*
 NSString *ingredientText = @"";
 NSMutableArray *ingredientAmountArray;
 NSString *foundData = @"";
 NSURL *url = [NSURL URLWithString:@"http://allrecipes.com/Recipe/Toll-House-Pie-I/Detail.aspx?event8=1&prop24=SR_Thumb&e11=tollhouse%20pie&e8=Quick%20Search&event10=1&e7=Home%20Page&soid=sr_results_p1i1&rank=1"];
 NSData *data = [NSData dataWithContentsOfURL:url];
 NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 
 NSScanner *scanner = [NSScanner scannerWithString:pageSource];
 //loop through the html data
 while(![scanner isAtEnd]){
 NSInteger leftPos, rightPos;
 [scanner scanUpToString:@"ingredient-amount\">" intoString:nil];
 leftPos = [scanner scanLocation];
 if(![scanner scanUpToString:@"</span>" intoString:nil]){
 break;
 }
 rightPos = [scanner scanLocation] + 1;
 leftPos += 20;
 foundData = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 2)];
 ingredientText = [ingredientText stringByAppendingString: [NSString stringWithFormat:@"\n\n%@",foundData]];
 }
 
 NSString *ingredientText = @"";
 NSMutableArray *ingredientAmountArray;
 NSString *foundData = @"";
 NSURL *url = [NSURL URLWithString:@"http://allrecipes.com/Recipe/Toll-House-Pie-I/Detail.aspx?event8=1&prop24=SR_Thumb&e11=tollhouse%20pie&e8=Quick%20Search&event10=1&e7=Home%20Page&soid=sr_results_p1i1&rank=1"];
 NSURL *url = [NSURL URLWithString:@"http://allrecipes.com/Recipe/Tollhouse-Pie/Detail.aspx?event8=1&prop24=SR_Title&e11=tollhouse%20pie&e8=Quick%20Search&event10=1&e7=Home%20Page&soid=sr_results_p1i1"];
 NSData *data = [NSData dataWithContentsOfURL:url];
 NSString *pageSource = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 
 
 NSScanner *scanner = [NSScanner scannerWithString:pageSource];
 
 //loop through the html data
 while(![scanner isAtEnd]){
 NSInteger leftPos, rightPos;
 
 [scanner scanUpToString:@"ingredient-amount\">" intoString:nil];
 leftPos = [scanner scanLocation];
 
 if(![scanner scanUpToString:@"</span>" intoString:nil]){
 break;
 }
 rightPos = [scanner scanLocation] + 1;
 
 //remember counting starts at 0, so if the word is 3 long, leftPos += 2
 leftPos += 19;
 foundData = [pageSource substringWithRange: NSMakeRange(leftPos, (rightPos - leftPos) - 1)];
 ingredientText = [ingredientText stringByAppendingString: [NSString stringWithFormat:@"\n%@",foundData]];
 
 }
 
 _webData.text = ingredientText;
 */
