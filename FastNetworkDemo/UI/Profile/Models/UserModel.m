//
//  UserModel.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "UserModel.h"
#import "BaseResponse.h"

@implementation UserModel

- (instancetype)initWithUserResponse:(UserResponse *)response {
    if (self = [super init]) {
        NSString *name = [NSString stringWithFormat:@"Name: %@", response.name];
        NSString *username = [NSString stringWithFormat:@"Username: %@", response.username];
        NSString *email = [NSString stringWithFormat:@"Email: %@", response.email];
        NSString *phone = [NSString stringWithFormat:@"Phone: %@", response.phone];
        NSString *website = [NSString stringWithFormat:@"Website: %@", response.website];
        NSString *address = [NSString stringWithFormat:@"Address: %@, %@, %@", response.address.city, response.address.street, response.address.zipcode];
        NSString *company = [NSString stringWithFormat:@"Company: %@", response.company.name];
        _profiles = @[name, username, email, phone, website, address, name, company];
    }
    return self;
}

@end
