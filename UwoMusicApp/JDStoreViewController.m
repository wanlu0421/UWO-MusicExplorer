//
//  JDStoreViewController.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDStoreViewController.h"

#import "JDStoreSongSearchTableViewCell.h"

@interface JDStoreViewController ()

@property(strong, nonatomic) NSArray* dataArray;
@property(strong, nonatomic) NSArray* searchResults;

@end

@implementation JDStoreViewController

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
    // Do any additional setup after loading the view.
    
    self.dataArray = [[NSArray alloc] init];
    self.searchResults = [[NSArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.dataArray count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"cellId";
    
    JDSongDescriptorRestModel* song = (JDSongDescriptorRestModel*)[self.dataArray objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell = [[JDStoreSongSearchTableViewCell alloc] initWithSong:song reuseIdentifier:cellId];


    return cell;
}

#pragma Search Methods



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search button clicked");
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString* queryString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([queryString length] != 0) {
        [JDSongDescriptorRestModel
         searchSongsTitle:queryString
         Artist:queryString
         Genre:queryString
         Success:^(NSArray* songs) {
             self.dataArray = songs;
             [searchTableView reloadData];
         }
         Failure:^(NSError* error) {
             NSLog(error);
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    songSelection = (JDSongDescriptorRestModel*)[self.dataArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"songDetailsPush" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"songDetailsPush"]) {
        JDStoreSongDetailsViewController* songDetails = (JDStoreSongDetailsViewController*)[segue destinationViewController];
        [songDetails setSongSelection:songSelection];
    }
}

@end
