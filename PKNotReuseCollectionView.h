//
//  PKNotReuseCollectionView.h
//  Pocket
//
//  Created by Loong on 16/8/12.
//  Copyright © 2016年 音悦Tai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PKNotReuseCollectionView;

typedef enum : NSUInteger {
    Horizontal,
    Vertical,
    
} ScrollDirection;

@protocol PKNotReuseCollectionViewDelegate <NSObject>

-(NSUInteger)numberOfItemInNotResueCollectionView:(PKNotReuseCollectionView *)notReuseCollection;

-(UIView *)notResueCollectionView:(PKNotReuseCollectionView *)notReuseCollection viewForIndex:(NSInteger)index;

-(CGSize)notResueCollectionView:(PKNotReuseCollectionView *)notReuseCollection viewSizeForIndex:(NSInteger)index;

-(void)notResueCollectionViewDidEndScrollingAnimation:(PKNotReuseCollectionView *)notReuseCollection and:(UIView *)view and:(NSInteger)index;

@end

@interface PKNotReuseCollectionView : UIScrollView

@property(nonatomic,weak)IBOutlet id <PKNotReuseCollectionViewDelegate> dataSource;

@property(nonatomic)ScrollDirection direction;


-(__kindof UIView *)viewFromDequeWithBlock:(NSInteger)index andBlock:(UIView* (^)())block;


-(void)reloadItemAtIndex:(NSInteger)index andBlock:(void(^)(id view))block;


-(void)scrollToRectWithIndex:(NSInteger)index;



@end
