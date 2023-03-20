//
//  CLCompanyFeature.h
//  Car2Life
//
//  Created by Andrey on 18.07.22.
//  Copyright © 2022 NGSE. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol CLCompanyFeature
@end

@interface CLCompanyFeature : JSONModel

@property NSNumber *companyTypeId;
@property NSNumber *companyFeatureId;
@property NSString *name;
@property NSString *icon;

@end
