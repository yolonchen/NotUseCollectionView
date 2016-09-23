//
//  PKNotReuseCollectionView.m
//  Pocket
//
//  Created by Loong on 16/8/12.
//  Copyright © 2016年 音悦Tai. All rights reserved.
//

#import "PKNotReuseCollectionView.h"

@interface PKNotReuseCollectionView()<UIScrollViewDelegate>

@property(nonatomic,strong)NSMutableArray *viewArr;
@property(nonatomic,strong)NSMutableArray *frameArr;
@property(nonatomic,strong)NSMutableArray *visibleArr;

@property(nonatomic,strong)UIView *bgView;

@end


@implementation PKNotReuseCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib{
    //[self layoutIfNeeded];
    
    
    
    
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}


-(void)setDataSource:(id<PKNotReuseCollectionViewDelegate>)dataSource{
    self.delegate = self;
    _dataSource = dataSource;
    
    self.direction = Horizontal;
    self.contentSize = [self notReuseCollectionViewContentSize];
    
    [self configureViewWithContentOffset:CGPointMake(0, 0)];
}

-(NSMutableArray *)frameArr{
    if (!_frameArr) {
        _frameArr = [NSMutableArray array];
    }
    return _frameArr;
}

-(NSMutableArray *)viewArr{
    if (!_viewArr) {
        _viewArr = [NSMutableArray array];
    }
    return _viewArr;
}



-(NSMutableArray *)visibleArr{
    if (!_visibleArr) {
        _visibleArr = [NSMutableArray array];
    }
    return _visibleArr;
}


-(void)reloadItemAtIndex:(NSInteger)index andBlock:(void(^)(id view))block{
    UIView *view = self.viewArr[index];
    block(view);
}



-(__kindof UIView *)viewFromDequeWithBlock:(NSInteger)index andBlock:(UIView* (^)())block{
    if (self.viewArr.count >= index + 1) {
        return self.viewArr[index];
    }else{
        UIView *view = block();
        
        [self.viewArr addObject:view];
        
        return view;
    }
}


-(CGSize)notReuseCollectionViewContentSize{
    NSUInteger numberOfItem = [self.dataSource numberOfItemInNotResueCollectionView:self];
    CGFloat contentWidth = 0;
    CGFloat contentHeight = 0;
    CGRect rect = CGRectZero;
    for (NSInteger i = 0; i < numberOfItem; i++) {
        
        CGSize contentSize = [self.dataSource notResueCollectionView:self viewSizeForIndex:i];
        
        if (self.direction == Vertical) {
            contentHeight += contentSize.height;
            contentWidth = contentSize.width;
            CGFloat x = 0.0f;
            CGFloat y = CGRectGetMaxY(rect);
            
            rect = CGRectMake(x, y, contentSize.width, contentSize.height);
            
        }else if (self.direction == Horizontal){
            contentWidth += contentSize.width;
            contentHeight = contentSize.height;
            CGFloat x = CGRectGetMaxX(rect);
            CGFloat y = 0.0f;
            
            rect = CGRectMake(x, y, contentSize.width, contentSize.height);
        }
        [self.frameArr addObject:[NSValue valueWithCGRect:rect]];
    }
    
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    
    [self addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
        make.width.equalTo(@(contentSize.width));
        make.height.equalTo(@(contentSize.height));
    }];
    
    return contentSize;
}

-(void)configureViewWithContentOffset:(CGPoint)point{
    
    CGFloat maxLoaction = 0;
    
    if (self.direction == Horizontal) {
        maxLoaction = SCREEN_WIDTH + point.x;
    }else if (self.direction == Vertical){
        
        maxLoaction = CGRectGetHeight(self.bounds) + point.y;
    }
    
    for (NSInteger i = 0; i < self.frameArr.count; i++) {
        if ((i < self.visibleArr.count)) {
            continue;
        }
        
        NSValue *rectValue = self.frameArr[i];
        
        CGRect rect = [rectValue CGRectValue];
        
        if (self.direction == Horizontal) {
            if (maxLoaction < CGRectGetMinX(rect)) {
                break;
            }
        }else if (self.direction == Vertical){
            if (maxLoaction < CGRectGetMinY(rect)) {
                break;
            }
            
        }
        
        if (self.direction == Horizontal) {
            if (maxLoaction >= CGRectGetMinX(rect)) {
                UIView *view = [self.dataSource notResueCollectionView:self viewForIndex:i];
                [self.bgView addSubview:view];
                [self.visibleArr addObject:[NSNumber numberWithBool:YES]];
                //view.frame = rect;
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.bgView.top).offset(CGRectGetMinY(rect));
                    make.left.equalTo(self.bgView.left).offset(CGRectGetMinX(rect));
                    make.width.equalTo(CGRectGetWidth(rect));
                    make.height.equalTo(CGRectGetHeight(rect));
                }];
                
                self.visibleArr[i] = [NSNumber numberWithBool:YES];
            }
        }else if (self.direction == Vertical){
            
            if (maxLoaction >= CGRectGetMinY(rect)) {
                UIView *view = [self.dataSource notResueCollectionView:self viewForIndex:i];
                [self.bgView addSubview:view];
                [self.visibleArr addObject:[NSNumber numberWithBool:YES]];
                //view.frame = rect;
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.bgView.top).offset(CGRectGetMinY(rect));
                    make.left.equalTo(self.bgView.left).offset(CGRectGetMinX(rect));
                    make.width.equalTo(CGRectGetWidth(rect));
                    make.height.equalTo(CGRectGetHeight(rect));
                }];
                self.visibleArr[i] = [NSNumber numberWithBool:YES];
            }
        }
    }
}


-(void)scrollToRectWithIndex:(NSInteger)index{
    self.contentOffset = CGPointMake(SCREEN_WIDTH * index, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
    
    if (self.visibleArr.count == self.frameArr.count) {
        return;
    }
    
    [self configureViewWithContentOffset:scrollView.contentOffset];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CGFloat x = self.contentOffset.x;
    
    for (NSInteger i = 0; i < self.frameArr.count; i++){
        
        NSValue *rectValue = self.frameArr[i];
        
        CGRect rect = [rectValue CGRectValue];
        
        if (CGRectGetMinX(rect) == x) {
            UIView *view = [self.dataSource notResueCollectionView:self viewForIndex:i];
            
            [self.dataSource notResueCollectionViewDidEndScrollingAnimation:self and:view and:i];
            
            break;
        }
    }
}




@end
