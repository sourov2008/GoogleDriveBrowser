 
 ![googledrivebanner](https://user-images.githubusercontent.com/4990835/37694966-9808cede-2cf5-11e8-8610-a5d2aa16d2bb.jpg)
 
 GoogleDriveBrowser provides a simple and effective way to browse, and download files using the Google Drive SDK. In a few minutes you can install Google Drive Browser to configure google credential first.
 
 # Features
 Google Drive browse and Download file . There is a default query for fetching file but you may customise your query . You may open your file with browser(safari).
 
 ## User Interface
 GoogleDriveBrowser has a simple UITableView interface . You can customise cell icon and donwload icon . By default there is a file fetching Loading indicator , Download progress bar with donwload progress text . Added tableview pull to refresh and file overview.
 
 <p align="center"><img width="1193" alt="googledrivebrowser" src="https://user-images.githubusercontent.com/4990835/37695498-0190c7fe-2cfa-11e8-821c-2b9247a9ea11.png" align="center"/></p>
 
 ## Files
 When a user taps on download button file will download and called the delegate method while downloading file .Also Called delegate method both success/failoure  completion
 
 ## Folder
  In folder case recursively push untill file not found.
 
 # Project Details
 Learn more about the project requirements, licensing, contributions, and setup.
 
 ## Requirements
 Greater than or eqaul iOS 9
 
 
 ## Contributions
 Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.
 
 ## Installation - Via Cocoapods
 Follow the instructions below to properly integrate GoogleDriveBrowser into your project.
 
     pod ‘GoogleDriveBrowser’

 
 ### Google Configuration (Both Objective C and Swift)
 
 1. Configure Google Drive [Turn on the Drive API](https://developers.google.com/drive/v3/web/quickstart/ios#step_1_turn_on_the_api_name) and setup your app. Follow the Step 1
 
 2. Drag and drop downloaded GoogleService-Info.plist file into your project
 
 3. Open the GoogleService-Info.plist configuration file, and look for the REVERSED_CLIENT_ID key. Copy the value of that key, and paste it into the URL Schemes box on the configuration view.
 
 ### Setup in Obj C
  
 4. Add in AppDelegate.h file
 
         #import <Google/SignIn.h> 
 
 5. In Appdelegate.m file add the following lines of code
 
         - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
             NSError* configureError;
             [[GGLContext sharedInstance] configureWithError: &configureError];
             NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
 
             return YES;
         }
 
         - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
         return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
         }

 4. in your desired class in .h file add following code
 
           #import "SDGDTableViewController.h"
 Implement the  
          `SDGDTableViewControllerDelegate` 
 Once implemented, you'll recieve calls when a file is downloaded or fails to download or progressValue. Like 
          
          @interface YourClassName : UIViewController <SDGDTableViewControllerDelegate>
 
 
 5. in your desired class in .m file add this line of code
 
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"SDGD"
                                                         bundle:nil];
        SDGDTableViewController *obj=
            [storyboard instantiateViewControllerWithIdentifier:@"SDGDTableViewController"];
    
        obj.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:obj];
        [self presentViewController:nav animated:YES completion:nil];

 ### Setup in Swift
 
  1. Add the following line into your into your Bridging header file

        #import  <GoogleDriveBrowser/SDGDTableViewController.h>
 
  2. Add the following line into your into your AppDelegate.swift file
 
         import Google

  3. Add the following line into your into your applicationDidFinishLaunching function in AppDelegate.swift file
         
         var configureError: NSError?
         GGLContext.sharedInstance().configureWithError(&configureError)
         assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")

  4. Add the following functions into your into your AppDelegate.swift file

         func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
         }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

  5. Add the following lines of code In your desired class

         var  obj = SDGDTableViewController() ;
         let storyboard : UIStoryboard = UIStoryboard(name: "SDGD", bundle: nil)
         obj = storyboard.instantiateViewController(withIdentifier: "SDGDTableViewController") as! SDGDTableViewController
         obj.delegate = self
         let nav = UINavigationController.init(rootViewController: obj)
         self.present(nav, animated: true, completion: {
         })
         
  By Default library image will load on google file view . You may change those images

 
 ### Installation - Manual (Both Objective C and Swift)
 - Download the project and add SDGDTableViewController.h and SDGDTableViewController.m file in your project
 - Follow this step given above  ### Google Configuration (Both Objective C and Swift)
 - include those library via pod
 - pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
 - pod 'Google/SignIn', '~> 3.0.3'

 
 ### Example Project Run
  - Download GoogleDriveBrowser 
  - Install the podfile of Example folder 
  - Follow Google Configure Setups 
  - Open GoogleDriveBrowser.xcworkspace file and run the project.
  
   ### Delegate Methods 
   
   Most important delegates methods are given here . See more delegate methods on SDGDTableViewController.h file

      /**
      *  File download Progress value . You may use your own progressbar presentation depends on this values
      *  @param downloaded  is download data size instant thread
      *  @param totalDownloaded is  Total downloaded data size
      *  @param fileInfo  from file info you may get file size
      */
     - (void)delegateDownloadProgress: (GTLRDrive_File *)fileInfo downloadByte:(float)downloaded totalRecived : (float)totalDownloaded;


      /**
       *  Download successfull
       *  Delegate Downloaded Data with File Info.
       *
       */
      - (void)delegateDownloadedFileWithFileDetails: (GTLRDrive_File *)fileInfo downloadedData: (NSData*)data;
      
      
Enjoy GoogleDriveBrowser


   

  
  
