//
//  GetVenueInfoViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 5/28/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "GetVenueInfoViewController.h"
#import "CreateVenueViewController.h"
#import "CreateVirtualVenueViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DebugViewController.h"

@interface GetVenueInfoViewController ()

@end

@implementation GetVenueInfoViewController
{
    CGPoint originalCenter;
}

@synthesize venueNameTextField = _venueNameTextField;
@synthesize streetAddressTextField = _streetAddressTextField;
@synthesize cityTextField = _cityTextField;
@synthesize stateTextField = _stateTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //originalCenter = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITextField Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    
    if(originalCenter.y == 0)
        originalCenter = self.view.center;
    
    if(self.view.center.y != originalCenter.y)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y);// - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    if(originalCenter.y == 0)
        originalCenter = self.view.center;
    
    if( (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) && (self.view.center.y == originalCenter.y) )
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField:shouldChangeCharactersInRange: %lu replacementString: %@", (unsigned long)range.length, string);
    
    // 
    if( (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) && (self.view.center.y != originalCenter.y) )
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
    
    // 
    if ([string isEqualToString:@"#"])
    {
        return NO;
    }
    else if(textField.tag == 4 && textField.text.length >= 2 && range.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag != 1 && textField.tag < 4)
    {
        UITextField *nextTextField = (UITextField *)[self.view viewWithTag:(textField.tag+1)];
        [nextTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma IBOutlets
- (IBAction)didClickDebugButton:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DebugViewController *debugViewController = [sb instantiateViewControllerWithIdentifier:@"DebugViewController"];
    [self presentViewController: debugViewController animated:YES completion:nil];
}

- (IBAction)didClickSendLocation:(id)sender
{
    //[self getScenesInCity:_cityTextField.text andState:[_stateTextField.text uppercaseString]];
    
    // If everything is not correctly selected, return an error
    if([self isEverythingSelectedAndCorrect] == false)
    {
        return;
    }
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@,%@", _streetAddressTextField.text, _cityTextField.text, _stateTextField.text];
    
    NSString *lookUpString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressString];
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:nil];
    
    NSArray *locationArray = [[[jsonDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
    
    if(locationArray == nil)
    {
        // Let the user know that it was a failure
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Invalid address..."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    locationArray = [locationArray objectAtIndex:0];
    
    NSString *latitudeString = [locationArray valueForKey:@"lat"];
    NSString *longitudeString = [locationArray valueForKey:@"lng"];
    
    NSLog(@"LatitudeString:%@ & LongitudeString:%@", latitudeString, longitudeString);
    
    // Open next view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults objectForKey:@"signUpButton"] isEqualToString:@"signUp"])
    {
        // Capture Screenshot
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil);
        
        CreateVenueViewController *createVenueViewController = [sb instantiateViewControllerWithIdentifier:@"CreateVenueViewController"];
        createVenueViewController.venueNameString = _venueNameTextField.text;
        createVenueViewController.streetAddressString = _streetAddressTextField.text;
        createVenueViewController.cityString = _cityTextField.text;
        createVenueViewController.stateString = _stateTextField.text;
        createVenueViewController.latitudeString = latitudeString;
        createVenueViewController.longitudeString = longitudeString;
        
        [self.navigationController pushViewController:createVenueViewController animated:YES];
    }
    else if([[defaults objectForKey:@"signUpButton"] isEqualToString:@"adHoc"])
    {
        CreateVirtualVenueViewController *createVirtualVenueViewController = [sb instantiateViewControllerWithIdentifier:@"CreateVirtualVenueViewController"];
        createVirtualVenueViewController.venueNameString = _venueNameTextField.text;
        createVirtualVenueViewController.streetAddressString = _streetAddressTextField.text;
        createVirtualVenueViewController.cityString = _cityTextField.text;
        createVirtualVenueViewController.stateString = _stateTextField.text;
        createVirtualVenueViewController.latitudeString = latitudeString;
        createVirtualVenueViewController.longitudeString = longitudeString;
        
        [self.navigationController pushViewController:createVirtualVenueViewController animated:YES];
    }
}

- (BOOL)isEverythingSelectedAndCorrect
{
    NSString *errorMsg;
    
    if(_venueNameTextField.text.length == 0)
        errorMsg = @"Venue name must contain at least one character...";
    else if(_streetAddressTextField.text.length == 0)
        errorMsg = @"Illegal address...";
    else
        return true;
    
    // Let the user know that it was a failure
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    return false;
}

@end
