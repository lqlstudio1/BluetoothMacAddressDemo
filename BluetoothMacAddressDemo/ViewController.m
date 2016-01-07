//
//  ViewController.m
//  BluetoothMacAddressDemo
//
//  Created by MacPu on 16/1/7.
//  Copyright © 2016年 www.imxingzhe.com. All rights reserved.
//

#import "ViewController.h"
#import "MPBluetoothKit.h"

NSString *const kPeripheralCellIdentifier = @"kPeripheralCellIdentifier";

@interface ViewController ()

@property (nonatomic, strong) MPCentralManager *centralManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Searching peripherals";
    
    __weak typeof(self) weakSelf = self;
    _centralManager = [[MPCentralManager alloc] initWithQueue:nil];
    [_centralManager setUpdateStateBlock:^(MPCentralManager *centralManager){
        if(centralManager.state == CBCentralManagerStatePoweredOn){
            [weakSelf scanPeripehrals];
        }
        else{
            [weakSelf.tableView reloadData];
        }
    }];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPeripheralCellIdentifier];
}

- (void)scanPeripehrals
{
    __weak typeof(self) weakSelf = self;
    if(_centralManager.state == CBCentralManagerStatePoweredOn){
        [_centralManager scanForPeripheralsWithServices:nil options:nil withBlock:^(MPCentralManager *centralManager, MPPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)connectPeripheral:(MPPeripheral *)peripheral
{
    __weak typeof(self) weakSelf = self;
    [_centralManager connectPeripheral:peripheral options:nil withSuccessBlock:^(MPCentralManager *centralManager, MPPeripheral *peripheral1) {
        [weakSelf getMacAddress:peripheral1];
    } withDisConnectBlock:^(MPCentralManager *centralManager, MPPeripheral *peripheral, NSError *error) {
        NSLog(@"disconnectd %@",peripheral.name);
    }];
}

- (void)getMacAddress:(MPPeripheral *)peripheral
{
    [peripheral discoverServices:nil withBlock:^(MPPeripheral *peripheral1, NSError *error) {
        for(MPService *service in peripheral1.services){
            
        }
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_centralManager.discoveredPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPeripheralCellIdentifier forIndexPath:indexPath];
    
    MPPeripheral *peripheral = [_centralManager.discoveredPeripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",[peripheral.RSSI integerValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MPPeripheral *peripheral = [_centralManager.discoveredPeripherals objectAtIndex:indexPath.row];
    [self connectPeripheral:peripheral];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

@end
