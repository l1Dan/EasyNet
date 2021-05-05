//
//  PhotosTableViewCell.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <SDWebImage/SDWebImage.h>

#import "PhotosTableViewCell.h"

#import "PhotoModel.h"

@implementation PhotosTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.numberOfLines = 0;
        self.imageView.layer.cornerRadius = 12;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setPhotoModel:(PhotoModel *)photoModel {
    _photoModel = photoModel;
    self.textLabel.text = photoModel.title;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoModel.thumbnailUrl]];
}

@end
