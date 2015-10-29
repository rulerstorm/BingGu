//
//  myTabBarButton.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "myTabBarButton.h"

@implementation myTabBarButton

- (void)setMyTitle:(NSString *)myTitle
{
 
    _myTitle = myTitle;
    
    [self setTitle:myTitle forState:UIControlStateNormal];
    [self setTitle:myTitle forState:UIControlStateSelected];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor: [UIColor colorWithRed:117.0/255.0 green:117.0/255.0  blue:117.0/255.0  alpha:1.0] forState:UIControlStateNormal];
    
    NSString* imageName = [NSString stringWithFormat:@"%ld%@", _myIndex+1, myTitle];
    NSString* selectedImageName = [NSString stringWithFormat:@"%ld%@－选中", _myIndex+1, myTitle];

//    NSLog(@"%@", selectedImageName);
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    self.imageView.contentMode = UIViewContentModeCenter;

    
}

-(void)setMyIndex:(NSInteger)myIndex
{
    _myIndex = myIndex;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageH = contentRect.size.height * 0.6;
    CGFloat imageW = contentRect.size.width;
    return CGRectMake(0, 2, imageW, imageH);

}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height * 0.6;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    return CGRectMake(0, titleY, titleW, titleH);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
