#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <SpringBoard/SBWiFiManager.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

@interface IPListener : NSObject<LAListener, UIAlertViewDelegate>
{
@private
	UIAlertView *av;
}
@end

@implementation IPListener

- (BOOL)dismiss
{
	if (av)
	{
		[av dismissWithClickedButtonIndex:[av cancelButtonIndex] animated:YES];
		[av release];

		av = nil;
		return YES;
	}

	return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[av release];
	av = nil;
}

- (NSString *)getIPAddress
{
	NSString *address = @"(none)";

	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;

	int success = 0;

	success = getifaddrs(&interfaces);

	if (success == 0)
	{
		temp_addr = interfaces;

		while(temp_addr != NULL)
 		{
 			if(temp_addr->ifa_addr->sa_family == AF_INET)
 			{
 				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
 					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
			}

			temp_addr = temp_addr->ifa_next;
		}
	}

	freeifaddrs(interfaces);

	return address;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (![self dismiss])
	{
		NSString *ssid = [[objc_getClass ("SBWiFiManager") sharedInstance] currentNetworkName];

		if(!ssid)
			av = [[UIAlertView alloc] initWithTitle:nil message:@"No network detected." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		else
			av = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"SSID: %@\nIP: %@", ssid, self.getIPAddress] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

		[av show];
		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	[self dismiss];
}

@end
 
