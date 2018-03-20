//
//  SDGDTableViewController.m
//  GoogleDriveBroswer
//
//  Created by BS-23 on 2/18/18.
//  Copyright © 2018 shourov datta. All rights reserved.
//

#import "SDGDTableViewController.h"

#define FILE_OBJECT_STORE_KEY @"GD_persistedFILE"
@interface SDGDTableViewController ()

/// The controller's main download progress view.
@property (nonatomic, weak)    UIProgressView *downloadProgressView;
@property (nonatomic, strong)  UIActivityIndicatorView *indicator;
@property (nonatomic, strong)  UILabel *lblnoData;
@property (nonatomic, strong)  UIView *progressView;
@property (nonatomic, strong)  UILabel *lblProgress;

@property (nonatomic, strong)  GTLRDriveService *service;
@property (nonatomic, strong)  GTMSessionFetcher *fetcher;

@property (nonatomic, strong)  IBOutlet GIDSignInButton *signInButton;
@property (nonatomic, strong)  NSMutableArray *fileListArray;
@property NSString *folderID;


@end

@implementation SDGDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileListArray = [NSMutableArray array];
    self.navigationItem.title = self.title;
    if (self.colorTheme == nil) self.colorTheme = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
    self.view.tintColor = self.colorTheme;
    
    [self UISetup];
    
    /// Only first time auth and sign in button will appear
    if (self.navigationController.viewControllers.count == 1) {
        [self performSelector:@selector(GDAuth) withObject:self afterDelay:0.5 ];
        self.signInButton = [[GIDSignInButton alloc] init];
        
        [self.view addSubview:self.signInButton];
        self.signInButton.center = self.view.center;
        
    }
    else{
        [self.indicator startAnimating];
        [self listFiles];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.navigationItem.title = self.title;
}

-(void)UISetup{
    
    UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:footerView];
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2, 5)];
    [self.tableView setTableHeaderView:headerView];
    
    float navWidth , navHeight;
    navHeight = self.navigationController.navigationBar.bounds.size.height;
    navWidth = self.navigationController.navigationBar.bounds.size.width;
    
    
    // done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnActionDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
#pragma mark - refresh controls
    // Add a refresh control, pull down to refresh
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = self.colorTheme;
        [refreshControl addTarget:self action:@selector(listFiles) forControlEvents:UIControlEventValueChanged];
        if (@available(iOS 10.0, *)) {
            self.tableView.refreshControl = refreshControl;
        } else {
            // Fallback on earlier versions
        }
    }
    
#pragma mark - Progress view bellow Navigation Bar
    if (self.isEnableProgressView) {
        
        // Add Download Progress view bellow Navigation Bar
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat yOrigin = navHeight-newProgressView.bounds.size.height;
        CGFloat widthBoundary = navWidth;
        CGFloat heigthBoundary = newProgressView.bounds.size.height;
        newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
        
        newProgressView.alpha = 0.0;
        newProgressView.tintColor = self.colorTheme;
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
        newProgressView.transform = transform;
        
        [self.navigationController.navigationBar addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
        
        /// Add Progress label over navigation bar
        self.progressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, navWidth, navHeight-3)];
        self.lblProgress = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, navWidth, navHeight-3)];
        self.lblProgress.textColor = [UIColor blackColor];
        [self.lblProgress setFont:[UIFont systemFontOfSize:16]];
        self.lblProgress.text = @"";
        [self.progressView addSubview:_lblProgress];
        [self.navigationController.navigationBar addSubview:self.progressView];
        self.progressView.backgroundColor = [UIColor whiteColor];
        self.progressView.hidden = true;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self
                   action:@selector(btnActionCancelDownload)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Cancel" forState:UIControlStateNormal];
        //[button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(self.navigationController.navigationBar.bounds.size.width-65, 0, 50, navHeight);
        [self.progressView addSubview:button];
        
    }
    
#pragma mark - Network Indicator
    // Network Indicator
    if (self.isEnableActivityIndicator) {
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
        self.indicator.color = self.colorTheme;
        self.indicator.center = self.view.center;
        [self.view addSubview:self.indicator];
        [self.indicator bringSubviewToFront:self.view];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    }
    /// No data founds label
#pragma mark - No data founds label
    self.lblnoData = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 50, self.view.frame.size.width, 30)];
    self.lblnoData.text = @"";
    [self.view addSubview:self.lblnoData];
    //self.lblnoData.center = self.view.center;
    self.lblnoData.textAlignment = NSTextAlignmentCenter;
    [self.lblnoData bringSubviewToFront:self.view];
    
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        _folderID = @"root";// Default Folder ID is root
        self.isEnablefileViewOption = YES;
        self.isEnableProgressView = YES;
        self.isEnableActivityIndicator = YES;
    }
    return self;
}



#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    self.service = [[GTLRDriveService alloc] init];
    if (error != nil) {
        //[self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
        if ([self.delegate respondsToSelector:@selector(delegateSignInError:)]) {
            [self.delegate delegateSignInError:error];
        }
        NSLog(@"Login Error : %@", error);
        
    } else {
        [self.indicator startAnimating];
        self.signInButton.hidden = true;
        self.service.authorizer = user.authentication.fetcherAuthorizer;
        [self listFiles];
        
    }
}


#pragma mark - Class Methods

-(void)GDAuth{
    
    // Configure Google Sign-in.
    GIDSignIn* signIn = [GIDSignIn sharedInstance];
    if (self.isSignOutSilently) {
        [signIn signOut];
        self.isSignOutSilently = NO;
    }
    
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveReadonly, nil];
    [signIn signInSilently];
    
}

- (void)updateDownloadProgress:(CGFloat)progress {
    if (self.downloadProgressView.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.downloadProgressView.alpha = 1.0;
        }];
    }
    
    [self.downloadProgressView setProgress:progress];
}

-(void)downloadFile : (GTLRDrive_File *)file{
    
    /// If there is any download in queue the cancelled this
    if ([self.fetcher isFetching]) {
        [self btnActionCancelDownload];
    }
    
    
    self.progressView.hidden = false;
    ///Initialize the Downloading data label
    if (file.size != nil) {
        self.lblProgress.text =  [NSString stringWithFormat:@"Downloading 0 KB of %@",[NSByteCountFormatter stringFromByteCount:[file.size longLongValue] countStyle:NSByteCountFormatterCountStyleFile] ];
    }
    else{
        self.lblProgress.text =   @"Downloading...";
    }
    
    
    __weak typeof(self) weakSelf = self;
    NSURLRequest *downloadRequest;
    
    // Google Format File
    if (file.fileExtension== nil) {
        // Google Spread Sheet like googles own format can be downloaded via this query
        //https://developers.google.com/drive/v3/web/manage-downloads
        GTLRDriveQuery_FilesExport *query = [GTLRDriveQuery_FilesExport queryForMediaWithFileId:file.identifier mimeType:@"application/pdf"];
        downloadRequest = [self.service requestForQuery:query];
        
    }
    
    // files with binary content (non google format drive file) must have fileExtension
    else{
        GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file.identifier];
        downloadRequest = [self.service requestForQuery:query];
        
    }
    
    self.fetcher = [self.service.fetcherService fetcherWithRequest:downloadRequest];
    
    // Progress
    [self.fetcher setReceivedProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        
        float progress = ((float)totalBytesWritten/[file.size floatValue]);
        [weakSelf updateDownloadProgress:progress];
        
        if (file.size!=nil) {
            weakSelf.lblProgress.text = [NSString stringWithFormat:@"Downloading %@ of %@",[NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile] , [NSByteCountFormatter stringFromByteCount:[file.size longLongValue] countStyle:NSByteCountFormatterCountStyleFile] ];
        }
        
        else{
            weakSelf.lblProgress.text = [NSString stringWithFormat:@"Downloading.. %@ ",[NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile] ];
            
        }
        
        
        if ([weakSelf.delegate respondsToSelector:@selector(delegateDownloadProgress:downloadByte:totalRecived:)]) {
            [weakSelf.delegate delegateDownloadProgress:file downloadByte:bytesWritten totalRecived:totalBytesWritten];
        }
        
        
        
    }];
    
    
    // Download Completion Handler
    [self.fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *fetchError) {
        self.progressView.hidden = true;
        self.lblProgress.text = @"";
        [UIView animateWithDuration:0.3 animations:^{
            self.downloadProgressView.alpha = 0.0;
            self.downloadProgressView.progress = 0.0;
        }];
        
        if (fetchError == nil) {
            
            // Download succeeded.
            NSLog(@"Download succeeded.");
            // Hide the progress bar and reset to zero
            if ([self.delegate respondsToSelector:@selector(delegateDownloadedFileWithFileDetails:downloadedData:)]) {
                [self.delegate delegateDownloadedFileWithFileDetails:file downloadedData:data];
            }
            
            
            //Add successful notification just bellow Navigation
            if (self.isEnableProgressView) {
                
                UIView *viewSuccessNoti = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 30)];
                viewSuccessNoti.backgroundColor =  [UIColor colorWithRed:92/255.0 green:195/255.0 blue:138/255.0 alpha:1];
                
                UILabel *lblDLSuccess = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 30)];
                lblDLSuccess.textColor = [UIColor blackColor];
                [lblDLSuccess setFont:[UIFont systemFontOfSize:18]];
                lblDLSuccess.textColor = [UIColor whiteColor];
                lblDLSuccess.textAlignment = NSTextAlignmentCenter;
                lblDLSuccess.text = @"Successfully Downloaded";
                
                [viewSuccessNoti addSubview:lblDLSuccess];
                
                viewSuccessNoti.alpha = 0.0;
                [self.navigationController.navigationBar addSubview:viewSuccessNoti];
                
                [UIView animateWithDuration:0.8
                                 animations:^{viewSuccessNoti.alpha = 1.0;}
                                 completion:^(BOOL finished){
                                     [viewSuccessNoti removeFromSuperview];
                                     
                                 }];
                
            }
            
        }
        
        else{
            NSLog(@"%@", fetchError.description);
            
            [self btnActionCancelDownload];
            [self showAlert:@"Error" message:fetchError.localizedDescription];
            if ([self.delegate respondsToSelector:@selector(delegateDownloadedFileFailure:errorDetails:)]) {
                [self.delegate delegateDownloadedFileFailure:file errorDetails:fetchError];
            }
            
        }
    }];
    
    
}



- (void)refreshTableView{
    
    GTLRDrive_FileList *result = [self storeOutFileObject];
    NSMutableString *output = [[NSMutableString alloc] init];
    [self.fileListArray removeAllObjects];
    //self.signInButton.hidden = true;
    //[self.signInButton removeFromSuperview];
    
    if (result.files.count > 0) {
        [output appendString:@"Files:\n"];
        int count = 1;
        for (GTLRDrive_File *file in result.files) {
            //file.fileExtension
            //file.mimeType
            [output appendFormat:@"%@ (%@)\n", file.name, file.identifier];
            NSLog(@"Output name = %@",file.name);
            count++;
            [self.fileListArray addObject:file];
        }
        [self.tableView reloadData];
        if (@available(iOS 10.0, *)) {
            [self.tableView.refreshControl endRefreshing];
        } else {
            // Fallback on earlier versions
        }
        
    } else {
        self.lblnoData.text = @"No files found.";
        [output appendString:@"No files found."];
    }
    //self.output.text = output;
    
}



#pragma mark - UITV

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fileListArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseableIdentifire];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseableIdentifire];
    }
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    GTLRDrive_File *file = self.fileListArray[indexPath.row];
    NSString *fileExtension= @"",*fileSize=@"";
    
    /// Check if folder
    if (file.fileExtension == nil && [file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        // This is folder
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        fileExtension = @"Folder";
        
    }
    
    cell.accessoryView = nil;
    
    /// Download Button
    if (  ![file.mimeType isEqualToString:@"application/vnd.google-apps.folder"] ) {
        
        // File Extension
        if (file.size) {
            fileSize = [NSByteCountFormatter stringFromByteCount:[file.size longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        }
        
        if (file.fileExtension) {
            fileExtension = file.fileExtension;
        }
        
        
        
        // Add download button
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downloadButton setFrame:CGRectMake(0, 0, 25, 25)];
        [downloadButton setBackgroundImage:[UIImage imageNamed:self.donwloadBtnImageName] forState:UIControlStateNormal];
        cell.accessoryView = downloadButton;
        [downloadButton bringSubviewToFront:self.view];
        downloadButton.tag = indexPath.row;
        [downloadButton addTarget:self action:@selector(btnDownloadAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@",fileExtension,fileSize];
    
    // Icon setup from user
    if ([self.delegate respondsToSelector:@selector(delegateSetFIleOrFolderIcon:)]) {
        cell.imageView.image = [self.delegate delegateSetFIleOrFolderIcon:file];
    }
    
    // Default Icon
    else
    {
        if ( ![self checkIsEmptyString:file.fileExtension] ) {
            cell.imageView.image = [UIImage imageNamed:file.fileExtension];
            // If image still not found the default image
            if (!cell.imageView.image) {
                cell.imageView.image = [UIImage imageNamed:@"file"];
            }
        }
        
        else if (file.fileExtension == nil && [file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
            cell.imageView.image = [UIImage imageNamed:@"folder"];
        }
        
        else
            cell.imageView.image = [UIImage imageNamed:@"file"];
    }
    
    cell.accessoryView.tintColor = self.colorTheme;
    cell.textLabel.text = file.name;
    cell.textLabel.lineBreakMode =  NSLineBreakByTruncatingMiddle;
    ;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GTLRDrive_File *file = self.fileListArray[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(delegateSelectedFileOrFolderInfo:)]) {
        [self.delegate delegateSelectedFileOrFolderInfo: file];
    }
    // If only folder then will go next step
    if (file.fileExtension == nil && [file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        SDGDTableViewController *obj = [storyboard instantiateViewControllerWithIdentifier:@"SDGDTableViewController"];
        
        obj.folderID = file.identifier;
        obj.service = self.service;
        obj.title = file.name;
        obj.delegate = self.delegate;
        obj.colorTheme = self.colorTheme;
        obj.donwloadBtnImageName = self.donwloadBtnImageName;
        obj.reuseableIdentifire = self.reuseableIdentifire;
        obj.isEnablefileViewOption = self.isEnablefileViewOption;
        obj.isEnableProgressView = self.isEnableProgressView;
        obj.isEnableActivityIndicator =self.isEnableActivityIndicator;
        
        [self.navigationController pushViewController:obj animated:YES];
    }
    else // Download or open with safari
    {
        // Open with browser
        if (self.isEnablefileViewOption) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:file.webViewLink] options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:file.webViewLink]];
            }
            
        }
        // Download the file
        else{
            [self downloadFile:file];
        }
        
        
    }
    
}

#pragma mark - Google Drive


// List up to 1000 files in Drive
- (void)listFiles {
    
    self.lblnoData.text = @"";
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    if ([self.delegate respondsToSelector:@selector(delegateFileListingDidStart)]) {
        [self.delegate delegateFileListingDidStart];
    }
    
    if ([self.delegate respondsToSelector:@selector(delegateSetQueryWithFolderID:)]) {
        query = [self.delegate delegateSetQueryWithFolderID:_folderID];
        
    }
    
    else{
        
        query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,fileExtension,size, createdTime,modifiedTime)";
        query.pageSize = 1000;
        query.q = [NSString stringWithFormat:@"trashed = false and '%@' In parents ",_folderID];
        
    }
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Process the response and display output
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRDrive_FileList *)result
                          error:(NSError *)error {
    
    if (@available(iOS 10.0, *)) {
        [self.tableView.refreshControl endRefreshing];
    } else {
        // Fallback on earlier versions
    }
    [self.indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
    
    if (error == nil) {
        [self storeInFileObject:result];
        if ([self.delegate respondsToSelector:@selector(delegateFileListingDidFinishedSuccessed:)]) {
            [self.delegate delegateFileListingDidFinishedSuccessed:result];
        }
        [self.fileListArray removeAllObjects];
        [self refreshTableView];
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(delegateFileRetrievalError:)]) {
            [self.delegate delegateFileRetrievalError:error];
        }
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}



#pragma mark - Storing

-(void)storeInFileObject:(GTLRDrive_FileList *)fileModel
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (!fileModel)
    {
        [defaults removeObjectForKey:FILE_OBJECT_STORE_KEY];
        return;
    }
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:fileModel];
    
    NSDictionary *viewIndetifierDict = [[NSDictionary alloc]initWithObjectsAndKeys:encodedObject,@"viewIndetifierDict", nil];
    [defaults setObject:viewIndetifierDict forKey:FILE_OBJECT_STORE_KEY];
    [defaults synchronize];
}

-(GTLRDrive_FileList *)storeOutFileObject
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *viewIndetifierDict = (NSDictionary *)[defaults objectForKey:FILE_OBJECT_STORE_KEY];
    
    NSData *encodedObject = [viewIndetifierDict objectForKey:@"viewIndetifierDict"];
    GTLRDrive_FileList *fileModel = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return fileModel;
}

#pragma mark - Actions

- (IBAction) btnDownloadAction: (id)sender{
    GTLRDrive_File *file = self.fileListArray[[sender tag]];
    [self downloadFile:file];
}

-(void)btnActionDone{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
    if ([self.delegate respondsToSelector:@selector(delegateDoneButtonTapped)]) {
        [self.delegate delegateDoneButtonTapped];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)btnActionCancelDownload{
    
    [self.fetcher stopFetching];
    self.progressView.hidden = true;
    self.lblProgress.text = @"";
    [UIView animateWithDuration:0.3 animations:^{
        self.downloadProgressView.alpha = 0.0;
        self.downloadProgressView.progress = 0.0;
    }];
    
}

#pragma mark - Helper Functions

-(BOOL)checkIsEmptyString:( NSString*_Nullable)str{
    
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:charSet];
    if ([trimmedString isEqualToString:@""]) {
        // it's empty or contains only white spaces
        return YES;
    }
    
    if(str==nil  || [str isKindOfClass:[NSNull class]] || str.length==0 || [str isEqualToString:@""]|| [str isEqualToString:@"(null)"] || [str isEqualToString:@"<null>"]){
        return YES;
    }
    return NO;
    
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


@end

