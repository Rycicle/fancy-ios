//    Copyright 2011 Felipe Cypriano
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "FCRangeSlider.h"

#define FIXED_HEIGHT 30.0f

@interface FCRangeSlider (Private)
- (void)clipThumbToBounds;
- (void)updateInRangeTrackView;
- (void)swtichThumbsPositionIfNecessary;
- (void)updateRangeValue;
@end

@implementation FCRangeSlider

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize range;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, FIXED_HEIGHT)];
    if (self) {
        minimumValue = 0.0f;
        maximumValue = 100.0f;
        
        outRangeTrackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 10)];
        outRangeTrackView.contentMode = UIViewContentModeScaleToFill;
        outRangeTrackView.backgroundColor = [UIColor darkGrayColor];
        outRangeTrackView.layer.cornerRadius = 5;
        [self addSubview:outRangeTrackView];

        inRangeTrackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 10)];
        inRangeTrackView.contentMode = UIViewContentModeScaleToFill;
        inRangeTrackView.backgroundColor = [UIColor blueColor];
        inRangeTrackView.layer.cornerRadius = 5;
        [self addSubview:inRangeTrackView];
        
        minimumThumbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_thumb"]];
        minimumThumbView.frame = CGRectSetPosition(minimumThumbView.frame, 0, 3);
        [self addSubview:minimumThumbView];

        maximumThumbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_thumb"]];
        maximumThumbView.frame = CGRectSetPosition(minimumThumbView.frame, frame.size.width - 24, 3);
        [self addSubview:maximumThumbView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.frame = CGRectSetHeight(self.frame, FIXED_HEIGHT);
    }
    return self;
}

- (void)dealloc {
    [minimumThumbView release];
    [inRangeTrackView release];
    [outRangeTrackView release];
    [super dealloc];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:CGRectSetHeight(newFrame, FIXED_HEIGHT)];
}

#pragma mark -
#pragma mark Drag handling

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(minimumThumbView.frame, touchPoint)) {
        thumbBeingDragged = minimumThumbView;
    } else if (CGRectContainsPoint(maximumThumbView.frame, touchPoint)) {
        thumbBeingDragged = maximumThumbView;
    } else {
        [self cancelTrackingWithEvent:event];
        thumbBeingDragged = nil;
        return NO;
    }
    
    thumbBeingDragged.highlighted = YES;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (thumbBeingDragged) {
        CGPoint touchPoint = [touch locationInView:self];
        thumbBeingDragged.center = CGPointMake(touchPoint.x, thumbBeingDragged.center.y);
        [self clipThumbToBounds];
        [self swtichThumbsPositionIfNecessary];
        [self updateInRangeTrackView];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return YES;
    } else {
        return NO;
    }
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    thumbBeingDragged.highlighted = NO;
    thumbBeingDragged = nil;
}

#pragma mark -
#pragma mark Private methods

- (void)clipThumbToBounds {
    if (thumbBeingDragged.frame.origin.x < 0) {
        thumbBeingDragged.frame = CGRectSetPositionX(thumbBeingDragged.frame, 0);
    } else if (thumbBeingDragged.frame.origin.x + thumbBeingDragged.bounds.size.width > self.bounds.size.width) {
        thumbBeingDragged.frame = CGRectSetPositionX(thumbBeingDragged.frame, self.bounds.size.width - thumbBeingDragged.bounds.size.width);
    }    
}

- (void)swtichThumbsPositionIfNecessary {
    if (thumbBeingDragged == minimumThumbView && thumbBeingDragged.frame.origin.x >= CGRectEndValue(maximumThumbView.frame)) {
        minimumThumbView = maximumThumbView;
        maximumThumbView = thumbBeingDragged;
    } else if (thumbBeingDragged == maximumThumbView && CGRectEndValue(thumbBeingDragged.frame) <= minimumThumbView.frame.origin.x) {
        maximumThumbView = minimumThumbView;
        minimumThumbView = thumbBeingDragged;
    }
}

- (void)updateInRangeTrackView {
    CGFloat newX = minimumThumbView.frame.origin.x;
    CGFloat newWidth = maximumThumbView.frame.origin.x + maximumThumbView.bounds.size.width - newX;
    inRangeTrackView.frame = CGRectMake(newX, inRangeTrackView.frame.origin.y, newWidth, inRangeTrackView.bounds.size.height);
}

- (void)updateRangeValue {
    // TODO calculate range value
}

@end
