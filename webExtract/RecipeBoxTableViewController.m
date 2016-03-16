//
//  RecipeBoxTableViewController.m
//  webExtract
//
//  Created by Nicole on 4/21/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "RecipeBoxTableViewController.h"
#import "RecipeBoxNameTableViewCell.h"

@interface RecipeBoxTableViewController ()

@end

@implementation RecipeBoxTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *docsDir;
    NSArray *dirPaths;
    _recipeBoxNames = [[NSMutableArray alloc] init];
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
        //NSString *querySQL = [NSString stringWithFormat:@"SELECT name FROM boxnames WHERE image = \"%@\"",@"BlueRecipe.png"] ;
        const char *query_stmt = [querySQL UTF8String];

        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *boxName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                [_recipeBoxNames addObject: boxName];
            }
        
            sqlite3_finalize(statement);
        }
        sqlite3_close(_recipeDB);
    }
}
    /*
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        NSString *sqlStatement=[NSString stringWithFormat:@"Select recipebox from recipes"];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database2, [sqlStatement UTF8String], -1, &compiledStatement, NULL)==SQLITE_OK){
            while(sqlite3_step(compiledStatement)==SQLITE_ROW){
                NSMutableDictionary *_dataDictionary2=[[NSMutableDictionary alloc] init];
                NSString *_recordRecipeBoxName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)];
                [_dataDictionary2 setObject:[NSString stringWithFormat:@"%@",_recordRecipeBoxName ] forKey:@"recipebox"];
                [_recipeBoxNames addObject: _dataDictionary2];
            }
        }
   
        else{
            NSLog(@"No Data Found");
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database2);
     */
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recipeBoxNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"recipeBoxNameCell";
    RecipeBoxNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    long row = [indexPath row];
    cell.RecipeBoxName.text = _recipeBoxNames[row];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController *transferViewController = segue.destinationViewController;
    if([segue.identifier isEqualToString:@"selectedBox"])
    {
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        long row = [myIndexPath row];
        transferViewController.recipeBoxName = _recipeBoxNames[row];
        transferViewController.saveMode = @"YES";

    }

    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
