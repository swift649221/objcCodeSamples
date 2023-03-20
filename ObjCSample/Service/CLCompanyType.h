//
//  CLCompanyType.h
//  Car2Life
//
//  Created by Andrey on 14.08.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import "JSONModel.h"

@interface CLCompanyType : JSONModel

@property NSNumber *companyTypeId;
@property NSNumber *count;
@property NSString *icon;
@property NSString *name;

//+ (JSONKeyMapper *)keyMapper;

@end
