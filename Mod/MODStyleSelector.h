//
//  MODStyleSelector.h
//  Mod
//
//  Created by Jonas Budelmann on 29/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MODStyleNode.h"

@interface MODStyleSelector : NSObject

/**
 *  Class of View to match
 */
@property (nonatomic, strong) Class viewClass;

/**
 *  If not nil checks the view's mod_styleClass property
 */
@property (nonatomic, strong) NSString *styleClass;

/**
 *  Whether or not to do strict matching against viewClass
 */
@property (nonatomic, assign) BOOL shouldSelectSubclasses;

/**
 *  Whether or not view has to be a direct subview or can be a descendant
 */
@property (nonatomic, assign) BOOL shouldSelectDescendants;

/**
 *  The style node linked to this selector
 */
@property (nonatomic, strong) MODStyleNode *node;

/**
 *  Parent selector
 */
@property (nonatomic, strong) MODStyleSelector *parentSelector;

/**
 *  Child selector
 */
@property (nonatomic, weak) MODStyleSelector *childSelector;

/**
 *  Returns a integer representation of how specific this selector is.
 *  Provides a way to order selectors.
 *
 *  The Rules
 *
 *  ViewClass matches
 *   +2 ancestor
 *   +3 superview
 *   +4 view
 *
 *   if loose match (shouldSelectSubclasses)
 *    -2
 *
 *  StyleClass matches
 *   +1000 ancestor
 *   +2000 superview
 *   +3000 view
 *
 *  @return Precendence score
 */
- (NSInteger)precedence;

/**
 *  Whether is selector matches the given view
 *
 *  @param view `UIView` or a subclass
 *
 *  @return `YES` if all selectors including parent selectors match the view
 */
- (BOOL)shouldSelectView:(UIView *)view;

/**
 *  Provides support for properties that have extra arguments such as
 *  - setTitle:forState:
 */
- (void)setArgumentValue:(MODToken *)argumentValue forKey:(MODToken *)key;

/**
 *  String representation of receiver
 *
 *  @return a `NSString` value
 */
- (NSString *)stringValue;

@end
