//
//  TPTopPlacesTableViewController.m
//  top-places
//
//  Created by Amr Lotfy on 9/30/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPTopPlacesTableViewController.h"
#import "TPDataLoader.h"

@interface TPTopPlacesTableViewController ()

@property (strong,nonatomic) UIRefreshControl * refreshControl;
@property (nonatomic) BOOL placesHashNeedsUpdate;
@property (strong,nonatomic) NSArray * countries;

@end

@implementation TPTopPlacesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@ viewDidLoad...", self.class );
    [self setRefreshControl];
    [self loadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadData

-(void) loadData{
    [self.refreshControl beginRefreshing];
    __weak TPTopPlacesTableViewController * weakSelf = self;
    void (^block)(BOOL success, NSArray *result) = ^(BOOL success, NSArray *result) {
        if (success) {
            weakSelf.topPlaces=result;
            NSLog(@"Loaded [%lu] top places entries.",result.count);
            self.countryHashedPlaces = [self hashPlacesByCountry];
            NSLog(@"Country-hashed-places: %@",[self countryHashedPlaces]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [weakSelf.refreshControl endRefreshing];
        });
    };
    
    [TPDataLoader getFlickrTopPlacesWithCompletion:block];
}

- (void)setRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - countryHashedPlaces

-(NSDictionary *) countryHashedPlaces{
    if (!_countryHashedPlaces) {
        _countryHashedPlaces= [self hashPlacesByCountry];
    }
    return _countryHashedPlaces;
}

-(NSDictionary *) getCountryCityAndStateName:(NSString *) commaSeparatedRegionContent{
    NSMutableDictionary * result=[@{} mutableCopy];
    if (commaSeparatedRegionContent) {
        NSArray * stringParts=[commaSeparatedRegionContent componentsSeparatedByString:@", "];
        if (stringParts.count == 3) {
            result[@"country"]=stringParts[2];
            result[@"city"]=stringParts[1];
            result[@"state"]=stringParts[0];
        }
    }
    NSLog(@"From [%@] Extracted Country data : [%@]",commaSeparatedRegionContent,result);
    return result;
}



#define SORT_KEY @"place_url"

-(NSDictionary *) hashPlacesByCountry{
    NSMutableDictionary * hashedPlaces=[@{} mutableCopy];
    NSMutableArray * countries = [@[] mutableCopy];
    //creating places hashed on country part
    
    for (NSDictionary * placeDictionary in self.topPlaces) {
        NSString * countryName=[self getCountryCityAndStateName:placeDictionary[@"_content"]][@"country"];
        if (!hashedPlaces[countryName]) {
            hashedPlaces[countryName] = [@[placeDictionary] mutableCopy];
            [countries addObject:countryName];
        }else{
            [hashedPlaces[countryName] addObject:placeDictionary];
        }
    }
    self.countries=countries;
    NSLog(@"Created Country-hashed place dictionary: %@",hashedPlaces);
    //TODO: sort on woe_name part
    for (NSString * countryName in countries) {
        hashedPlaces[countryName] = [hashedPlaces[countryName] sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2){
            return [obj1[SORT_KEY] compare: obj2[SORT_KEY]];
        }];
        NSLog(@"Sorted places of country[%@] : %@", countryName,hashedPlaces[countryName]);
    }
    return hashedPlaces;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"country count: %lu", self.countries.count);
    return self.countries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.countryHashedPlaces[self.countries[section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"places_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSString * countryName=self.countries[indexPath.section];
    NSArray * placesInACountry=self.countryHashedPlaces[countryName];
    NSDictionary * place=placesInACountry[indexPath.row];
    NSString * placeString=place[@"_content"];
    NSString * city = [self getCountryCityAndStateName:placeString][@"city"];
    NSString * state = [self getCountryCityAndStateName:placeString][@"state"];
    
    cell.textLabel.text = city;
    cell.detailTextLabel.text = state;
    NSLog(@"cell: %@",cell);
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#define PLACE_PHOTOS_SEGUES @"Goto_place_photos"

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}
@end
