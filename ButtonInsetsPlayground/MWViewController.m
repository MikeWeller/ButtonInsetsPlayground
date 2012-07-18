//
//  MWViewController.m
//  ButtonInsetsPlayground
//
//  Created by Michael Weller on 17.07.12.
//  Copyright (c) 2012 Michael Weller. All rights reserved.
//

#import "MWViewController.h"

/* Values must match up with segmented control indices */
enum MWInsetSelection {
	kMWInsetSelectionContentEdgeInsets = 0,
	kMWInsetSelectionImageEdgeInsets = 1,
	kMWInsetSelectionTitleEdgeInsets = 2
};

@interface MWViewController ()

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UISlider *topSlider;
@property (nonatomic, strong) IBOutlet UISlider *leftSlider;
@property (nonatomic, strong) IBOutlet UISlider *bottomSlider;
@property (nonatomic, strong) IBOutlet UISlider *rightSlider;

@property (nonatomic, strong) IBOutlet UILabel *currentValueLabel;

@property (nonatomic, copy) NSString *observedPropertyName;

@end

@implementation MWViewController

@synthesize button = _button;
@synthesize segmentedControl = _segmentedControl;
@synthesize topSlider = _topSlider;
@synthesize leftSlider = _leftSlider;
@synthesize bottomSlider = _bottomSlider;
@synthesize rightSlider = _rightSlider;
@synthesize observedPropertyName = _observedPropertyName;
@synthesize currentValueLabel = _currentValueLabel;

- (IBAction)selectedSegmentChanged:(id)sender {
	[self switchToCurrentlySelectedInset];
}

- (void)switchToCurrentlySelectedInset
{
	enum MWInsetSelection selection = self.segmentedControl.selectedSegmentIndex;
	[self switchToInset:selection];
}

- (void)switchToInset:(enum MWInsetSelection)insetSelection
{
	[self unobserveButtonProperty];
	NSString *propertyToObserve = [self propertyToObserveForInsetSelection:insetSelection];
	[self observePropertyNamed:propertyToObserve];
}

- (void)unobserveButtonProperty
{
	if (self.observedPropertyName) {
		[self.button removeObserver:self
				 forKeyPath:self.observedPropertyName];
		self.observedPropertyName = nil;
	}
}

- (NSString *)propertyToObserveForInsetSelection:(enum MWInsetSelection)insetSelection
{
	switch (self.segmentedControl.selectedSegmentIndex) {
		case kMWInsetSelectionContentEdgeInsets:
			return @"contentEdgeInsets";

		case kMWInsetSelectionImageEdgeInsets:
			return @"imageEdgeInsets";

		case kMWInsetSelectionTitleEdgeInsets:
			return @"titleEdgeInsets";

		default:
			NSAssert(0, nil);
			return nil;
	}
}

- (void)observePropertyNamed:(NSString *)propertyName
{
	NSAssert(!self.observedPropertyName, nil);

	[self.button addObserver:self
		      forKeyPath:propertyName
			 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
			 context:NULL];

	self.observedPropertyName = propertyName;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	id newValue = [change valueForKey:NSKeyValueChangeNewKey];
	NSAssert([newValue isKindOfClass:NSValue.class], nil);
	NSValue *wrappedInsetsValue = newValue;

	UIEdgeInsets insets = [wrappedInsetsValue UIEdgeInsetsValue];
	[self updateSlidersForInsets:insets];
	[self updateCurrentValueLabelForInsets:insets];
}

- (void)updateSlidersForInsets:(UIEdgeInsets)insets
{
	self.topSlider.value = insets.top;
	self.leftSlider.value = insets.left;
	self.bottomSlider.value = insets.bottom;
	self.rightSlider.value = insets.right;
}

- (void)updateCurrentValueLabelForInsets:(UIEdgeInsets)insets
{
	self.currentValueLabel.text = NSStringFromUIEdgeInsets(insets);
}

- (IBAction)sliderChanged:(id)sender {
	UIEdgeInsets insets = UIEdgeInsetsMake(self.topSlider.value,
					       self.leftSlider.value,
					       self.bottomSlider.value,
					       self.rightSlider.value);

	insets = [self pixelAlignedInsets:insets forScale:self.view.window.screen.scale];
	[self setCurrentlySelectedInsetsTo:insets];
}

- (UIEdgeInsets)pixelAlignedInsets:(UIEdgeInsets)insets forScale:(CGFloat)scale
{
	if (scale == 0.0f) {
		scale = [[UIScreen mainScreen] scale];
	}

	if (scale == 0.0f) {
		scale = 1.0f;
	}

	UIEdgeInsets result = insets;

	result.left = floorf(result.left * scale) / scale;
	result.top = floorf(result.top * scale) / scale;
	result.right = ceilf(result.right * scale) / scale;
	result.bottom = ceilf(result.bottom * scale) / scale;

	return result;
}

- (void)setCurrentlySelectedInsetsTo:(UIEdgeInsets)insets
{
	NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
	[self.button setValue:value forKeyPath:self.observedPropertyName];
	[self sizeButtonToFit];

#ifndef NDEBUG
	NSLog(@"Current insets changed to: %@", NSStringFromUIEdgeInsets(insets));
#endif
}

- (void)sizeButtonToFit
{
	CGSize size = [self.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
	self.button.frame = CGRectMake((self.view.bounds.size.width - size.width) / 2,
				       self.button.frame.origin.y,
				       size.width,
				       size.height);
}

- (IBAction)resetButtonPressed:(id)sender {
	[self setCurrentlySelectedInsetsTo:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setupButton];
	[self switchToCurrentlySelectedInset];
	[self sizeButtonToFit];
}

- (void)setupButton
{
	self.button.clipsToBounds = YES;
	[self.button setBackgroundImage:[self buttonBackgroundImage]
			       forState:UIControlStateNormal];
	self.button.titleLabel.backgroundColor = [UIColor redColor];
	self.button.imageView.clipsToBounds = YES;
	self.button.imageView.backgroundColor = [UIColor yellowColor];
}

- (UIImage *)buttonBackgroundImage
{
	UIImage *result = [UIImage imageNamed:@"buttonBackground.png"];
	return [result stretchableImageWithLeftCapWidth:15 topCapHeight:27];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	[self setButton:nil];
	[self setSegmentedControl:nil];
	[self setTopSlider:nil];
	[self setLeftSlider:nil];
	[self setBottomSlider:nil];
	[self setRightSlider:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
