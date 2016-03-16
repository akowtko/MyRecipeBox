//
//  RecipeListTableViewController.m
//  webExtract
//
//  Created by Nicole on 4/22/14.
//  Copyright (c) 2014 Kowtko. All rights reserved.
//

#import "RecipeListTableViewController.h"

@interface RecipeListTableViewController ()

@end

@implementation RecipeListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [self getRecipeSummary];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Damask.tif"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    _navBar.title = _recipeBoxName;
    NSString *docsDir;
    NSArray *dirPaths;

    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"recipes.db"]];
    [self getRecipeSummary];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)getRecipeSummary{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt *statement;
    
    //open the recipe box name database
    if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
    {
        _recipeNames = [[NSMutableArray alloc] init];
        
        NSString *querySQL = [NSString stringWithFormat: @"SELECT recipe FROM recipes WHERE recipebox = \"%@\"", _recipeBoxName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *recipeName = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                [_recipeNames addObject: recipeName];
                
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_recipeDB);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)tableView: (UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        const char *dbpath = [_databasePath UTF8String];
        sqlite3_stmt *statement;
        
        //open the recipe box name database
        if (sqlite3_open(dbpath, &_recipeDB) == SQLITE_OK)
        {
            long row = [indexPath row];
            NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM recipes WHERE recipe = \"%@\"", _recipeNames[row]];
            
            const char *query_stmt = [querySQL UTF8String];
            
            if(sqlite3_prepare_v2(_recipeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
                if(sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"%@ deleted",_recipeNames[row]);
                }
                else{
                    NSLog(@"Not deleted");
                }
                
                sqlite3_finalize(statement);
            }
            sqlite3_close(_recipeDB);
            [_recipeNames removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView endUpdates];
        [tableView reloadData];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _recipeNames.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *CellIdentifier = @"recipeCell";
    RecipeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    long row = [indexPath row];
    cell.recipeNameOutlet.text = _recipeNames[row];
    
    cell.backgroundColor = [UIColor clearColor];
    /*UIImageView *indexDivider = [[UIImageView alloc] init];
    indexDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"indexDividerNew2.tif"]];
    cell.backgroundView = indexDivider;
    cell.backgroundColor = [UIColor clearColor];
    */
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
    if ([[segue identifier] isEqualToString:@"showRecipeDetails"]) {
        RecipeViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        long row = [myIndexPath row];
        detailViewController.recipeName = _recipeNames[row];
    }
}


@end
