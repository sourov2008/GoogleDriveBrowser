 
 
 
 GoogleDriveBrowser provides a simple and effective way to browse, and download files using the Google Drive  and SDK. In a few minutes you can install Google Drive Browser But you have to configure google credential first.
 
 # Features
 Google Drive browse and Download file . There is a default query for fetching file but you may customise your query . You may open your file with browser(safari) .
 
 ## User Interface
 GoogleDriveBrowser has a simple UITableView interface . You can customise cell icon and donwload icon . By default there is a file fetching Loading indicator , Download progress bar with donwload progress text . Added tableview pull to refresh and file overview.
 
 
 ## Files
 When a user taps on download button file will download and called the delegate method while downloading file . Called delegate method both success/failoure  completion
 
 # Project Details
 Learn more about the project requirements, licensing, contributions, and setup.
 
 ## Requirements
 Greater than or eqaul iOS 9
 
 
 ## Contributions
 Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.
 
 ## Installation - Via Cocoapods
 Follow the instructions below to properly integrate GoogleDriveBrowser into your project.
 
 pod ‘GoogleDriveBrowser’
 
 
 ### Installation - Manual
 Download the project and add SDGDTableViewController.h and SDGDTableViewController.m file in your project
 include those library via pod
 pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
 pod 'Google/SignIn', '~> 3.0.3'
 ### Setup
 
 1. Configure Google Drive [Turn on the Drive API](https://developers.google.com/drive/v3/web/quickstart/ios#step_1_turn_on_the_api_name) and setup your app. Follow the Step 1
 
 2. Drag and drop downloaded GoogleService-Info.plist file into your project
 
 3. Open the GoogleService-Info.plist configuration file, and look for the REVERSED_CLIENT_ID key. Copy the value of that key, and paste it into the URL Schemes box on the configuration view.
 
 4. Add
 #import <Google/SignIn.h> in AppDelegate.h file
 
 5. In Appdelegate.m file add the following code
 
 
 - (BOOL)application:(UIApplication *)application
 didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 NSError* configureError;
 [[GGLContext sharedInstance] configureWithError: &configureError];
 NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
 
 return YES;
 }
 
 - (BOOL)application:(UIApplication *)application
 openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation {
 return [[GIDSignIn sharedInstance] handleURL:url
 sourceApplication:sourceApplication
 annotation:annotation];
 }
 
 4. Add a UITableViewController (xib file) in your storyboard . Select the identity inspector of this xib and write the class name "SDGDTableViewController" .
 
 5. Set the cell identifire of (first select the cell and then click attribute inspector )
 
 6. in your desired class in .h file
 
 add #import "SDGDTableViewController.h"
 Implement the `SDGDTableViewControllerDelegate`  Once implemented, you'll recieve calls when a file is downloaded or fails to download or progressValue.
 Like @interface YourClassName : UIViewController <SDGDTableViewControllerDelegate>
 
 
 7. in your desired class in .m file add this line of code
 
 SDGDTableViewController *obj =
 [storyboard instantiateViewControllerWithIdentifier:@"SDGDTableViewController"];
 obj.delegate = self;
 obj.reuseableIdentifire = @"Your_Cell_Identifire"// Set your cell reuse Identifire
 UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
 [self presentViewController:nav animated:YES completion:nil];
 

