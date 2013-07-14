//
//  GameCollectionViewLayout.m
//  Amalon iOS Example
//
//  Created by Brandon Smith on 7/13/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "GameCollectionViewLayout.h"

#define SIZE 100.0f
#define OFFSET 10.0f

@implementation GameCollectionViewLayout

- (CGSize)collectionViewContentSize;
{
    return (CGSize) {.width = self.collectionView.bounds.size.width, .height = self.collectionView.bounds.size.width};
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (indexPath.section == 0) {
        attributes.frame = [self frameForItemAtItemIndex:indexPath.item];
    } else {
        attributes.frame = [self frameForCenteredItem];
    }
    attributes.zIndex = indexPath.item;
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSInteger itemIndex = 0; itemIndex < [self.collectionView numberOfItemsInSection:0]; itemIndex++) {
        if (CGRectIntersectsRect(rect, [self frameForItemAtItemIndex:itemIndex])) {
            [result addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]]];
        }
    }
    
    if (CGRectIntersectsRect(rect, [self frameForCenteredItem])) {
        [result addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]];
    }
    return result;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds;
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

#pragma mark - Private

- (CGRect)frameForCenteredItem
{
    CGSize size = [self collectionViewContentSize];
    CGSize desiredSize = CGSizeMake(MIN(size.width, size.height), MIN(size.width, size.height));
    CGRect frame = (CGRect){.size = size, .origin = CGPointZero};
    
    return CGRectInset(frame, SIZE+OFFSET+(size.width - desiredSize.width)/2.0f, SIZE+OFFSET+(size.height - desiredSize.height)/2.0f);
}

- (CGRect)frameForItemAtItemIndex:(NSInteger)itemIndex;
{
    CGSize size = [self collectionViewContentSize];
    CGSize desiredSize = CGSizeMake(MIN(size.width, size.height), MIN(size.width, size.height));
    
    CGFloat d, r;
    d = (CGFloat)itemIndex/([self.collectionView numberOfItemsInSection:0])*M_PI*2.0f;
    r = desiredSize.width - SIZE;
    CGRect frame = (CGRect){
        .origin = (CGPoint){.x = (cosf(d)+1.0f)*r/2.0f, .y = (sinf(d)+1.0f)*r/2.0f},
        .size = (CGSize){.width = SIZE, .height = SIZE}
    };
    return CGRectOffset(frame, (size.width - desiredSize.width)/2.0f, (size.height - desiredSize.height)/2.0f);
}

@end
