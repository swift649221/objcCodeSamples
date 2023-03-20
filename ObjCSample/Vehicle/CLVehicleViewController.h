//
//  CLVehicleViewController.h
//  Car2Life
//
//  Created by Andrey on 05.07.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import "CLVehicle.h"
#import "CLViewController.h"

@interface CLVehicleViewController : CLViewController < UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property CLVehicle *existingVehicle;
@property BOOL firstAppLaunch;

@end
