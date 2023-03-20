//
//  CLVehicleViewController.m
//  Car2Life
//
//  Created by Andrey on 08.07.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import "CLVehicleViewController.h"

#import "CLAPIEngine.h"
#import "CLButtonCollectionCell.h"
#import "CLCarBodyCollectionCell.h"
#import "CLGosNumberCollectionCell.h"
#import "CLRouter.h"
#import "CLSelectCarCollectionCell.h"
#import "CLTitleCollectionReusableView.h"
#import "CLWheelSizeCollectionCell.h"

#import "ActionSheetPicker.h"

#import "CLVehicleBodyType.h"
#import "CLVehicleMark.h"
#import "CLVehicleModel.h"
#import "CLVehicleWheelSize.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface CLVehicleViewController () < GosNumberDelegate > {
    NSArray *headerTitles;

    CLVehicleMark *selectedMark;
    CLVehicleModel *selectedModel;
    CLVehicleBodyType *selectedBodyType;
    CLVehicleWheelSize *selectedWheelSize;
    NSString *autoGosNumber, *autoRegionNumber;

    NSArray *vehicleMarks;
    NSArray *vehicleModels;
    NSArray *vehicleBodyTypes;
    NSArray *vehicleWheelSizes;

    AbstractActionSheetPicker *actionSheetPicker;
}
@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

@end

@implementation CLVehicleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self.navigationController.viewControllers.firstObject isEqual:self]) {
        [self addBackNavigationButton];
    } else {
    }
    _contentCollectionView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
    _contentCollectionView.layer.borderWidth = 0.5f;
    _contentCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    headerTitles = @[ @"", @"Введите гос.номер", @"Выберите тип кузова", @"Размер колес", @"" ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_existingVehicle) {
        selectedModel = [[CLVehicleModel alloc] init];
        selectedModel.autoModelId = _existingVehicle.autoModelId;
        selectedModel.name = _existingVehicle.model;
        selectedBodyType = [[CLVehicleBodyType alloc] init];
        selectedBodyType.autoBodyTypeId = _existingVehicle.autoBodyTypeId;
        selectedWheelSize = [[CLVehicleWheelSize alloc] init];
        selectedWheelSize.autoWheelSizeId = _existingVehicle.autoWheelSizeId;
        [self parseGosNumber:_existingVehicle.number];
        [self getBodyTypes];
        [self getWheelSizes:selectedBodyType.autoBodyTypeId];
        self.navigationItem.title = @"Изменение авто";
    } else {
        autoRegionNumber = @"";
        autoGosNumber = @"";
        self.navigationItem.title = @"Добавление авто";
    }
}

- (void)parseGosNumber:(NSString *)gosNumber {
    autoGosNumber = [gosNumber substringToIndex:[CLGosNumberCollectionCell getGosNumberLength]];
    autoRegionNumber = [gosNumber substringFromIndex:[CLGosNumberCollectionCell getGosNumberLength]];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader) {

        CLTitleCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CLTitleCollectionReusableView" forIndexPath:indexPath];
        headerView.viewTitle.text = headerTitles[indexPath.section];

        return headerView;
    }

    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 1 || section == 3) {
        return CGSizeMake (CGRectGetWidth (_contentCollectionView.frame), 35);
    }
    if (section == 2) {
        return CGSizeMake (CGRectGetWidth (_contentCollectionView.frame), selectedModel ? 35 : 60);
    } else {
        return CGSizeZero;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
    case 0: {
        // добавить авто
        return 1;
    }
    case 1: {
        // гос номер
        return 1;
    }
    case 2: {
        return vehicleBodyTypes.count; //тип кузова
        break;
    }
    case 3: {
        return vehicleWheelSizes.count; // колеса
        break;
    }
    case 4: {
        // кнопка
        return 1;
    }
    default:
        return 0;
        break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id universalCell;
    switch (indexPath.section) {
    case 0: {
        CLSelectCarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLSelectCarCollectionCell" forIndexPath:indexPath];
        if (selectedModel) {
            cell.carTextLabel.text = selectedModel.name;
        } else {
            cell.carTextLabel.text = @"Выберите модель";
        }
        universalCell = cell;
        break;
    }
    case 1: {
        CLGosNumberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLGosNumberCollectionCell" forIndexPath:indexPath];
        cell.gosNumberDelegate = self;
        [cell setAutoNumber:autoGosNumber region:autoRegionNumber];
        universalCell = cell;
        break;
    }
    case 2: {
        CLCarBodyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLCarBodyCollectionCell" forIndexPath:indexPath];
        CLVehicleBodyType *currentBodyType = vehicleBodyTypes[indexPath.item];

        cell.carBodyTitle.text = currentBodyType.name;
        if (selectedBodyType != nil) {
            if ([selectedBodyType.autoBodyTypeId isEqual:currentBodyType.autoBodyTypeId]) {
                cell.carBodyImageView.backgroundColor = GREEN_COLOR;
                NSString *imageName = [NSString stringWithFormat:@"%@_sel", currentBodyType.icon];
                cell.carBodyImageView.image = [UIImage imageNamed:imageName];
            } else {
                cell.carBodyImageView.backgroundColor = LIGHT_GRAY_COLOR;
                cell.carBodyImageView.image = [UIImage imageNamed:currentBodyType.icon];
            }
        } else {
            if (currentBodyType.isSelected) {
                cell.carBodyImageView.backgroundColor = GREEN_COLOR;
                NSString *imageName = [NSString stringWithFormat:@"%@_sel", currentBodyType.icon];
                cell.carBodyImageView.image = [UIImage imageNamed:imageName];
            } else {
                cell.carBodyImageView.backgroundColor = LIGHT_GRAY_COLOR;
                cell.carBodyImageView.image = [UIImage imageNamed:currentBodyType.icon];
            }
        }

        universalCell = cell;
        break;
    }
    case 3: {
        CLWheelSizeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLWheelSizeCollectionCell" forIndexPath:indexPath];
        CLVehicleWheelSize *currentWheelSize = vehicleWheelSizes[indexPath.item];
        cell.wheelSizeLabel.text = currentWheelSize.name;

        if ([selectedWheelSize.autoWheelSizeId isEqual:currentWheelSize.autoWheelSizeId]) {
            cell.wheelSizeLabel.backgroundColor = GREEN_COLOR;
            cell.wheelSizeLabel.textColor = [UIColor whiteColor];
        } else {
            cell.wheelSizeLabel.backgroundColor = LIGHT_GRAY_COLOR;
            cell.wheelSizeLabel.textColor = [UIColor darkGrayColor];
        }
        universalCell = cell;
        break;
    }
    case 4: {
        CLButtonCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLButtonCollectionCell" forIndexPath:indexPath];
        if (_existingVehicle) {
            [cell.leftButton addTarget:self action:@selector (deleteCar:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightButton addTarget:self action:@selector (changeCar:) forControlEvents:UIControlEventTouchUpInside];
            cell.centralButton.hidden = YES;
            cell.leftButton.hidden = NO;
            cell.rightButton.hidden = NO;
        } else {
            if (_firstAppLaunch) {
                [cell.leftButton addTarget:self action:@selector (cancel:) forControlEvents:UIControlEventTouchUpInside];
                [cell.leftButton setTitle:@"ОТМЕНА" forState:UIControlStateNormal];
                [cell.rightButton addTarget:self action:@selector (addCar:) forControlEvents:UIControlEventTouchUpInside];
                [cell.rightButton setTitle:@"ДОБАВИТЬ" forState:UIControlStateNormal];
                cell.leftButton.hidden = NO;
                cell.rightButton.hidden = NO;
                cell.centralButton.hidden = YES;
            } else {
                [cell.centralButton addTarget:self action:@selector (addCar:) forControlEvents:UIControlEventTouchUpInside];
                cell.leftButton.hidden = YES;
                cell.rightButton.hidden = YES;
                cell.centralButton.hidden = NO;
            }
        }
        universalCell = cell;
        break;
    }
    default: {
        UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
        universalCell = cell;
        break;
    }
    }
    return universalCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0: {
        // добавить авто
        return CGSizeMake (CGRectGetWidth (collectionView.frame), 160);
    }
    case 1: {
        // гос номер
        return CGSizeMake (CGRectGetWidth (collectionView.frame), 45);
    }
    case 2: {
        //тип кузова
        return CGSizeMake (CGRectGetWidth (collectionView.frame) / 4, 110);
        break;
    }
    case 3: {
        // колеса
        return CGSizeMake (CGRectGetWidth (collectionView.frame) / 4, 100);
        break;
    }
    case 4: {
        // кнопка
        return CGSizeMake (CGRectGetWidth (collectionView.frame), 60);
    }
    default:
        return CGSizeZero;
        break;
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0: {
        [_contentCollectionView resignFirstResponder];
        [self.view endEditing:YES];
        [self getMarks];
        break;
    }
    case 1: {
        // гос номер
        break;
    }
    case 2: {
        //тип кузова
        selectedBodyType = vehicleBodyTypes[indexPath.item];
        selectedWheelSize = nil;
        [self getWheelSizes:selectedBodyType.autoBodyTypeId];

        break;
    }
    case 3: {
        // колеса
        selectedWheelSize = vehicleWheelSizes[indexPath.item];
        [collectionView reloadData];
        break;
    }
    default:
        break;
    }
}

- (void)addCar:(id)sender {

    if (![self isDataCorrect]) {
        return;
    }
    NSString *autoNumber = [NSString stringWithFormat:@"%@%@", autoGosNumber, autoRegionNumber];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] createVehicle:autoNumber
                                        modelId:selectedModel.autoModelId
                                     bodyTypeId:selectedBodyType.autoBodyTypeId
                                    wheelSizeId:selectedWheelSize.autoWheelSizeId
                                     completion:^(BOOL success, id object) {
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       if (success) {
                                           if ([self.navigationController.viewControllers.firstObject isEqual:self]) {
                                               [[CLRouter sharedInstance] rootSlideServicesViewController];
                                           } else {
                                               [self.navigationController popViewControllerAnimated:YES];
                                           }
                                       }
                                     }];
}
- (void)deleteCar:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] deleteVehicle:_existingVehicle.autoId completion:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          [self.navigationController popViewControllerAnimated:YES];
      }
    }];
}
- (void)changeCar:(id)sender {
    if (![self isDataCorrect]) {
        return;
    }
    NSString *autoNumber = [NSString stringWithFormat:@"%@%@", autoGosNumber, autoRegionNumber];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] editVehicle:_existingVehicle.autoId number:autoNumber modelId:selectedModel.autoModelId bodyTypeId:selectedBodyType.autoBodyTypeId wheelSizeId:selectedWheelSize.autoWheelSizeId completion:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          [self.navigationController popViewControllerAnimated:YES];
      }
    }];
}

- (void)cancel:(id)sender {
    [[CLRouter sharedInstance] rootSlideServicesViewController];
}

#pragma mark - Internet requests

- (void)getMarks {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] getVehicleMarks:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          vehicleMarks = object;
          [self showMarksForSelection];
      }
    }];
}

- (void)showMarksForSelection {
    NSMutableArray *markStrings = [[NSMutableArray alloc] init];
    for (CLVehicleMark *mark in vehicleMarks) {
        [markStrings addObject:mark.name];
    }
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Выберите марку" rows:markStrings initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
      selectedMark = vehicleMarks[selectedIndex];
      [self getModels];
    }
        cancelBlock:^(ActionSheetStringPicker *picker) {

        }
        origin:_contentCollectionView];
    [picker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker showActionSheetPicker];
}


- (void)getModels {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] getVehicleModelsByMarkId:selectedMark.autoMarkId completion:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          vehicleModels = object;
          [self showModelsForSelection];
      }
    }];
}

- (void)showModelsForSelection {
    if (!vehicleModels.count) {
        [self showOldAlert:@"Модели отсутствуют" description:nil];
        return;
    }

    NSMutableArray *modelsStrings = [[NSMutableArray alloc] init];
    for (CLVehicleModel *model in vehicleModels) {
        [modelsStrings addObject:model.name];
    }
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Выберите модель" rows:modelsStrings initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
      selectedBodyType = nil;
      selectedWheelSize = nil;
      selectedModel = vehicleModels[selectedIndex];
      [self getBodyTypes];
    }
        cancelBlock:^(ActionSheetStringPicker *picker) {

        }
        origin:_contentCollectionView];
    [picker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker showActionSheetPicker];
}

- (void)getBodyTypes {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] getVehicleBodyTypesByModelId:selectedModel.autoModelId completion:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:NO];
      if (success) {
          vehicleBodyTypes = object;
          if (!selectedWheelSize) {
              selectedBodyType = [self getSelectedBodyType];
          }
          [self getWheelSizes:selectedBodyType.autoBodyTypeId];

          [_contentCollectionView reloadData];
      }
    }];
}

- (CLVehicleBodyType *)getSelectedBodyType {
    for (CLVehicleBodyType *type in vehicleBodyTypes) {
        if (type.isSelected == YES) {
            return type;
        }
    }
    return nil;
}

- (void)getWheelSizes:(NSNumber *)autoBodyTypeId {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] getVehicleWheelSizesByBodyType:autoBodyTypeId completion:^(BOOL success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:NO];
      if (success) {
          vehicleWheelSizes = object;
          [_contentCollectionView reloadData];
      }
    }];
}

#pragma mark - gos number delegate

- (void)gosNumberWasEdited:(NSString *)gosNumber {
    autoGosNumber = gosNumber;
}
- (void)regionNumberWasEdited:(NSString *)regionNumber {
    autoRegionNumber = regionNumber;
}

#pragma mark - Utils

- (BOOL)isDataCorrect {
    if (autoGosNumber.length != [CLGosNumberCollectionCell getGosNumberLength] || (autoRegionNumber.length != [CLGosNumberCollectionCell getRegionNumberLength] - 1 && autoRegionNumber.length != [CLGosNumberCollectionCell getRegionNumberLength])) {
        [self showOldAlert:@"Введите корректный номер авто" description:nil];
        return NO;
    }

    if (selectedModel == nil || selectedBodyType == nil || selectedWheelSize == nil) {
        [self showOldAlert:@"Заполните данные об авто" description:nil];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet< UITouch * > *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
