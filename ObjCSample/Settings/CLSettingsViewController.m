//
//  CLOptionsViewCellViewController.m
//  Car2Life
//
//  Created by Andrey on 11.11.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import "ActionSheetPicker.h"
#import "CLAPIEngine.h"
#import "CLOptionTableViewCell.h"
#import "CLPersonal.h"
#import "CLSettingsViewController.h"
#import "CLSwitchMapTableCell.h"
#import "CLUserDefaults.h"
#import "CLVehicle.h"
#import "CLVehicleViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "UIView+CLDisplay.h"
#import "UIViewController+ECSlidingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CLSettingsViewController () < UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SwitchDelegate > {
    NSArray *vehicles;
    CLVehicle *selectedVehicle;
    CLPersonal *personal;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewCars;
@property (weak, nonatomic) IBOutlet UIView *personView;
@property (weak, nonatomic) IBOutlet UIImageView *personPhoto;
@property (weak, nonatomic) IBOutlet UITextField *personName;


@end

@implementation CLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Настройки";
    [self addSidebarNavigationButton];
    _personName.delegate = self;
    UITapGestureRecognizer *tapPhotoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (avatarPhotoTapped:)];
    [_personPhoto addGestureRecognizer:tapPhotoGesture];
    [_personView setShadow];
    _personView.layer.cornerRadius = 2;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.slidingViewController.panGesture.enabled = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CLAPIEngine sharedInstance] getPersonal:^(BOOL success, id object) {
      if (success) {
          personal = object;
          _personName.text = personal.username;
          [_personPhoto sd_setImageWithURL:[NSURL URLWithString:personal.userAvatarUrl] placeholderImage:[UIImage imageNamed:@"auto_select_car"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
              if (!error) {
                  _personPhoto.contentMode = UIViewContentModeScaleAspectFill;
              }
          }];
          [[CLAPIEngine sharedInstance] getVehicles:^(BOOL success, id object) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                vehicles = object;
                [_tableViewCars reloadData];
            } 
          }];
      } else {
          [MBProgressHUD hideHUDForView:self.view animated:YES];
      }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.slidingViewController.panGesture.enabled = NO;
}


- (void)avatarPhotoTapped:(id)sender {
    [_personName resignFirstResponder];
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"" rows:@[ @"Камера", @"Библиотека" ] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
      if (selectedIndex == 0) {
          [self whatSourceOpen:UIImagePickerControllerSourceTypeCamera];
      }
      if (selectedIndex == 1) {
          [self whatSourceOpen:UIImagePickerControllerSourceTypePhotoLibrary];
      }
    }
        cancelBlock:^(ActionSheetStringPicker *picker) {

        }
        origin:self.view];
    [picker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [picker showActionSheetPicker];
}

- (void)whatSourceOpen:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = type;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _personPhoto.image = chosenImage;
    [[CLAPIEngine sharedInstance] uploadAvatar:UIImageJPEGRepresentation (chosenImage, 1.0) completion:^(BOOL success, id object){
    }];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return vehicles.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CLOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
        CLVehicle *vehicle = vehicles[indexPath.row];
        cell.titleMark.text = vehicle.mark;
        cell.subtitleModel.text = vehicle.model;
        [cell.autoImageView sd_setImageWithURL:[NSURL URLWithString:vehicle.imageUrl] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        return cell;
    } else {
        CLSwitchMapTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CLSwitchMapTableCell"];
        cell.switchDelegate = self;
        [cell prepareCellView];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        selectedVehicle = vehicles[indexPath.row];
        [self performSegueWithIdentifier:@"toVehicleDetailsSegue" sender:self];
    }
}

- (IBAction)AddCar:(id)sender {
    selectedVehicle = nil;
    [self performSegueWithIdentifier:@"toVehicleDetailsSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVehicleDetailsSegue"]) {
        CLVehicleViewController *vc = segue.destinationViewController;
        vc.existingVehicle = selectedVehicle;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self editPersonal];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self editPersonal];
    return NO;
}

- (void)swichWasChanged {
    [self editPersonal];
}

- (void)editPersonal {
    [_personName resignFirstResponder];
    if (![self isValidInputWithTextField:_personName.text]) {
        [self showAlertView:@"Пустое поле быть не может" description:nil];
        return;
    }
    [[CLAPIEngine sharedInstance] editPersonalByName:_personName.text completion:^(BOOL success, id object) {
      if (success) {
          personal = object;
          _personName.text = personal.username;
      }
    }];
}


- (BOOL)isValidInputWithTextField:(NSString *)text {
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
