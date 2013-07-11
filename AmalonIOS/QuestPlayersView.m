//
//  QuestPlayersView
//  
//
//  Created by Smith, Brandon on 7/8/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "QuestPlayersView.h"

typedef NS_ENUM(NSUInteger, QuestApprovalState) {
    QuestApprovalStateNone = 0,
    QuestApprovalStateApproved = 1,
    QuestApprovalStateRejected = 2
};

@interface QuestPlayersView ()
@property (nonatomic, strong) NSArray *colors;
@end

UIBezierPath * CheckMark(CGRect frame)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2.0f;
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    
    return path;
};

UIBezierPath * XMark(CGRect frame)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2.0f;
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
    
    [path moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    
    return path;
};

void DrawCell(UIColor *color, CGRect frame, BOOL selected, QuestApprovalState approval)
{
    
    UIBezierPath *square = [UIBezierPath bezierPathWithRect:CGRectInset(frame, 8.0f, 8.0f)];
    
    if (selected) {
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(frame, 3.0f, 3.0f)];
        [[UIColor lightGrayColor] setFill];
        [[UIColor darkGrayColor] setStroke];
        [circle fill];
    }
    
    [color setFill];
    [square fill];
    [[UIColor whiteColor] setStroke];
    [square stroke];
    
    if (approval == QuestApprovalStateApproved) {
        CGRect left, right;
        CGRectDivide(frame, &left, &right, frame.size.width/2.0f, CGRectMinXEdge);
        CGRectDivide(right, &right, &left, frame.size.height/2.0f, CGRectMinYEdge);
        
        UIBezierPath *checkMark = CheckMark(CGRectInset(right, 4.0f, 4.0f));
        UIBezierPath *bubble = [UIBezierPath bezierPathWithOvalInRect:right];
        
        [[UIColor colorWithRed:20.0f/255.0f green:75.0f/255.0f blue:0.0f alpha:1.0f] setFill];
        [[UIColor whiteColor] setStroke];
        [bubble fill];
        [bubble stroke];
        [checkMark stroke];
    }
    
    if (approval == QuestApprovalStateRejected) {
        CGRect left, right;
        CGRectDivide(frame, &left, &right, frame.size.width/2.0f, CGRectMinXEdge);
        CGRectDivide(right, &right, &left, frame.size.height/2.0f, CGRectMinYEdge);
        
        UIBezierPath *xMark = XMark(CGRectInset(right, 4.0f, 4.0f));
        UIBezierPath *bubble = [UIBezierPath bezierPathWithOvalInRect:right];
        
        [[UIColor redColor] setFill];
        [[UIColor whiteColor] setStroke];
        [bubble fill];
        [bubble stroke];
        [xMark stroke];
    }
}

@implementation QuestPlayersView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playerCount = 10;
        self.colors = @[[UIColor redColor], [UIColor blueColor], [UIColor orangeColor],
                        [UIColor purpleColor], [UIColor brownColor], [UIColor yellowColor],
                        [UIColor magentaColor], [UIColor cyanColor], [UIColor blackColor], [UIColor greenColor]];
        self.selected = @[@NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO, @NO];
        self.approved = @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat indWid, indHgt, w, h;
    w = rect.size.width;
    h = rect.size.height;
    indWid = w / 10;
    indHgt = indWid;
    
    for (int i = 0; i < self.playerCount; i++) {
        CGRect frame = CGRectMake(i*indWid, 0, indWid, indWid);
        DrawCell(self.colors[i], frame, [self.selected[i] boolValue], [self.approved[i] intValue]);
    }
}

@end
