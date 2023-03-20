//
//  CLCompany.h
//  Car2Life
//
//  Created by Andrey on 05.07.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CLCompanyFeature.h"
#import "CLCompanyService.h"
@interface CLCompany : JSONModel

@property NSNumber *companyId;
@property NSString *name;
@property NSString *address;
@property NSNumber *distance;
@property NSNumber *rating;
@property NSNumber *lat;
@property NSNumber *lng;


@property NSString *previewImageUrl;
@property BOOL inFavorites;
@property NSArray *detailImagesUrls;
@property NSString *companyDescription;
@property NSString *schedule;
@property BOOL isOpen;
@property NSNumber *discount;

@property NSString *phone;
@property NSString *priceRange;
@property NSString *paymentMethods;
@property NSArray<CLCompanyFeature *> *features;
@property NSArray<CLCompanyService *> *services;
@property BOOL isBookingAvailable;

@end
