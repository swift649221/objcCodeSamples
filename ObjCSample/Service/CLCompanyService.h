//
//  CLCompanyService.h
//  Car2Life
//
//  Created by Andrey on 15.07.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol CLCompanyService
@end

@interface CLCompanyService : JSONModel

@property NSNumber *companyServiceId;
@property NSString *name;
@property NSNumber *price;
@property NSNumber *discount;
@end
