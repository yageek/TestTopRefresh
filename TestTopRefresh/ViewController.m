//
//  ViewController.m
//  TestTopRefresh
//
//  Created by Yannick Heinrich on 02/07/15.
//  Copyright (c) 2015 yageek. All rights reserved.
//

#import "ViewController.h"
#import "TopRefreshView.h"

@interface ViewController ()
@property(nonatomic, strong) NSMutableArray * array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = [[NSMutableArray alloc] init];
    [self.array addObject:@(-1)];

    [TopRefreshView attachBottomRefreshToScrollView:self.tableView target:self refreshAction:@selector(refreshTriggered:)];
//    [TopRefreshView attachTopRefreshToScrollView:self.tableView target:self refreshAction:@selector(refreshTriggered:)];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    static NSString *cellID = @"Cell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSNumber* numbER = self.array[indexPath.row];
    cell.textLabel.text = numbER.stringValue;
    return cell;
    
}

#pragma mark - 
#pragma mark -  Add data + refresh

- (void) refreshTriggered:(id) sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addData];
        [sender endRefreshing];
    });

}

- (void) addData
{
    static NSUInteger length = 10;
    static NSUInteger max = 0;
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (NSInteger index = 0; index < length; ++index) {
        
        NSNumber * number = @(length - index - 1 + max);
        array[index] = number;
    }
    
    max += length;

    NSIndexSet * indexset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0 , length)];
    [self.array insertObjects:array atIndexes:indexset];
    

    [self.tableView reloadData];
    
//    NSIndexPath * baseIndexPath = [NSIndexPath indexPathForRow:length inSection:0];
//    [self.tableView scrollToRowAtIndexPath:baseIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    

}
@end
