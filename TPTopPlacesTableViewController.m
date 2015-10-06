//
//  TPTopPlacesTableViewController.m
//  top-places
//
//  Created by Amr Lotfy on 9/30/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPTopPlacesTableViewController.h"
#import "TPDataLoader.h"
#import "FlickrFetcher.h"
#import "TPPhotoListTableViewController.h"
#import "TPHistory.h"
@interface TPTopPlacesTableViewController ()

@property (strong,nonatomic) NSArray * countries;
@property (strong, nonatomic) NSArray * topPlaces;
@property (strong,nonatomic) NSDictionary * countryHashedPlaces;

@end

@implementation TPTopPlacesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadData

-(void) loadData{
    [TPHistory cleanHistory];
    [self.refreshControl beginRefreshing];
    __weak TPTopPlacesTableViewController * weakSelf = self;
    void (^block)(BOOL success, NSArray *result) = ^(BOOL success, NSArray *result) {
        if (success) {
            weakSelf.topPlaces=result;
            NSLog(@"Loaded [%lu] top places entries.",(unsigned long)result.count);
            self.countryHashedPlaces = [self hashPlacesByCountry];
            //NSLog(@"Country-hashed-places: %@",[self countryHashedPlaces]);
        }
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [weakSelf.refreshControl endRefreshing];
       // });
    };
    
    [TPDataLoader getFlickrTopPlacesWithCompletion:block];
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
        result[@"country"]=stringParts[stringParts.count-1];
        result[@"city"]=stringParts[stringParts.count-2];
        if (stringParts.count == 3) {//sometimes = only 2
            result[@"state"]=stringParts[0];
        }else{
            result[@"state"]=stringParts[stringParts.count-2];
        }
    }
    //NSLog(@"From [%@] Extracted Country data : [%@]",commaSeparatedRegionContent,result);
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
    self.countries=[countries sortedArrayUsingSelector:@selector(compare:)];
    //NSLog(@"Created Country-hashed place dictionary: %@",hashedPlaces);
    //TODO: sort on woe_name part
    for (NSString * countryName in countries) {
        hashedPlaces[countryName] = [hashedPlaces[countryName] sortedArrayUsingComparator:^(NSDictionary * obj1, NSDictionary * obj2){
            return [obj1[SORT_KEY] compare: obj2[SORT_KEY]];
        }];
        //NSLog(@"Sorted places of country[%@] : %@", countryName,hashedPlaces[countryName]);
    }
    return hashedPlaces;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"country count: %lu", (unsigned long)self.countries.count);
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
    return cell;
}


#define PLACE_PHOTOS_SEGUES @"Goto_place_photos"


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSString * country = self.countries[selectedIndexPath.section];
    NSDictionary * place = self.countryHashedPlaces[country][selectedIndexPath.row];
    NSString * placeId = place[FLICKR_PLACE_ID];
    if ([segue.identifier isEqualToString:PLACE_PHOTOS_SEGUES]) {
        TPPhotoListTableViewController *photoListVC= (TPPhotoListTableViewController *)[segue destinationViewController];
        photoListVC.placeId=[placeId copy];
        NSLog(@"Selected place ID: %@",placeId);
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:PLACE_PHOTOS_SEGUES sender:nil];
}

@end
