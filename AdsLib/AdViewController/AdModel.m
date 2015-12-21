//
//  AdModel.m
//  Kangaroo.Superheroes
//
//  Created by Bipul Dev on 10/10/15.
//  Copyright © 2015 MastermindConsulting. All rights reserved.
//

#import "AdModel.h"
#import "AppDelegate.h"
#define kAdProfileKey @"adProfileKey"
@implementation AdModel
@synthesize adObject,managerObject;

-(id)initAdProfile
{
    if (self = [super init])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [prefs objectForKey:kAdProfileKey];
        if (!myEncodedObject)
        {
            self.adObject = [[AdMap alloc] init];
            [self synchronize];
            
        }
        else
        {
            self.adObject = [NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
            [self synchronize];
        }
        
    }
    return self;
}

+(NSString *)getScore
{
    NSString *strScore = [[NSUserDefaults standardUserDefaults] objectForKey:kScoreKey];
    if (strScore!=nil)
    {
        return strScore;
    }
    else
    {
        return @"0";
    }
    
}
+(void)updateScore:(NSString *)str
{
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:kScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)synchronize
{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kAdProfileKey];
    
    if (self.adObject != nil)
    {
        NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.adObject];
        [prefs setObject:myEncodedObject forKey:kAdProfileKey];
        [prefs synchronize];
    }
}

-(void)deleteUserInformation
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAdProfileKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
    //return @"EA2C772F-8C97-4D47-8E4D-ODB1E8C40A3E";
}

-(void)gettingAdProfileDetails
{
    NSString *strID = [self getUniqueDeviceIdentifierAsString];
    NSString *urlstr = [NSString stringWithFormat:urlTransactions,kPublisherID,kAdWallID,strID];
    managerObject = [AFHTTPRequestOperationManager manager];
    
    [managerObject GET:urlstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"%@",responseObject);
         if(responseObject!=nil) {
             NSDictionary *responce = responseObject;
             self.adObject.strPlayScore = [responce objectForKey:@"currency_count"];
             NSArray *array = [responce objectForKey:@"transactions"];
             if (array && array.count>0)
             {
                 [AdModel updateScore:[responce objectForKey:@"currency_count"]];
             }
             else
             {
                [AdModel updateScore:[responce objectForKey:@"currency_count"]];
             }
             
             [self synchronize];
             [self settingScore];
         }
//         else{
//             
//             self.adObject.strPlayScore = @"25";
//             [AdModel updateScore:@"25"];
//             [self synchronize];
//             [self settingScore];
//         }
         //successResponce(json);
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //failureResponce(error);
     }];
    
}

-(void)creatingUser
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kbaseurl,kcreatingUser];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self getUniqueDeviceIdentifierAsString],@"player_id", nil];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSLog(@"%@",json);
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        adObject.strPlayScore = [[json objectForKey:@"player_data"] objectForKey:@"score"];
//        adObject.strPlayerID = [[json objectForKey:@"player_data"] objectForKey:@"player_id"];
//        adObject.strPlayerName = [[json objectForKey:@"player_data"] objectForKey:@"player_name"];
      //  [self synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        
    }];
}

-(void)giftCardAPI:(NSDictionary *)dictParameters completionBlock:(void(^)(BOOL successful, NSString *message))completion
{
    NSString *urlstr = [NSString stringWithFormat:@"%@",kgiftCardAPI];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:dictParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSDictionary *dictResponse = json;
        
        if ([[dictResponse objectForKey:@"success"] intValue] == 1)
        {
            completion(TRUE,[dictResponse objectForKey:@"status"]);
        }
        else
        {
            completion(FALSE,[dictResponse objectForKey:@"status"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app removingActivityView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Something went wrong. Check your internet connection and try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }];

}

-(void)updatePointsExample
{
    NSURL *URL = [NSURL URLWithString:@"/adwall/api/publisher/15451/profile/3161/user/CBCAA5EE-8E77-41D1-97E1-CD39C25DC2D5/transactions.json?api_key=LxC153Y7ynp7gDjDjf84e3pfVtKwWnXboxX8Cl6drII9FtR4uyAiSzf4CFJX&currency_adjustment=24"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
}

-(void)updatePoints:(NSDictionary *)dictParameters
{
    NSString *strID = [self getUniqueDeviceIdentifierAsString];
    NSString *urlstr = [NSString stringWithFormat:urlCreateTransaction,kPublisherID,kAdWallID,strID,kKey,[dictParameters objectForKey:@"score"]];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSDictionary *dictResponse = json;

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app removingActivityView];
        
    }];
}

-(void)redeemPoints:(NSDictionary *)dictParameters
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kbaseurl,kredeemGift];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:dictParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSLog(@"%@",json);
        NSDictionary *dict = json;
        if ([[dict objectForKey:@"response_status"] intValue] == 1)
        {
            NSString *strUpdatedScore = [[dict objectForKey:@"redeem_info"] objectForKey:@"updated_score"];
            
            NSMutableDictionary *dictMutable = [NSMutableDictionary dictionaryWithDictionary:dictParameters];
            [dictMutable setObject:@"U5vRvm0stGkA6vBSpg" forKey:@"api_key"];
            [dictMutable setObject:@"card" forKey:@"payment_source"];
            [dictMutable setObject:[dictParameters objectForKey:@"redeem_amount"] forKey:@"gift[amount]"];
            [dictMutable setObject:[dictParameters objectForKey:@"email_id"] forKey:@"gift[recipient_email]"];
            [dictMutable setObject:[dictParameters objectForKey:@"player_name"] forKey:@"gift[recipient_name]"];
            [dictMutable setObject:@"Kangaroo Super Heros" forKey:@"gift[sender_name]"];
            [dictMutable setObject:@"Gift card from kangaroo" forKey:@"message_announce"];
#warning uncomment the below statement for testing purpose
          //  [dictMutable setObject:@"true" forKey:@"test_gift"];
            if ([[dictParameters objectForKey:@"gift_card_type"] isEqualToString:@"1"])
            {
                [self giftCardAPI:dictMutable completionBlock:^(BOOL successful,NSString *message) {
                    if (successful)
                    {
                        NSString *scoreToReduce = [NSString stringWithFormat:@"-%@",[[dict objectForKey:@"redeem_info"] objectForKey:@"redeem_score"]];
                        [AdModel updateScore:strUpdatedScore];
                        NSDictionary *dictUpdate = [NSDictionary dictionaryWithObjectsAndKeys:scoreToReduce,@"score",[dictParameters objectForKey:@"email_id"],@"email", nil];
                        [self updatePoints:dictUpdate];
                        NSLog(@"%@",dictMutable);
                        NSLog(@"%@",dictParameters);
                        AppDelegate *app =(AppDelegate *) [[UIApplication sharedApplication] delegate];
                        [app removingView];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"%@",[dict objectForKey:@"response_message"]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        NSMutableDictionary *dictMut = [NSMutableDictionary dictionaryWithDictionary:dictParameters];
                        [dictMut setObject:@"0" forKey:@"redeem_mode"];
                        //getting data from response
                        [dictMut setObject:[[dict objectForKey:@"redeem_info"] objectForKey:@"redeem_id"] forKey:@"redeem_id"];
                        [dictMut setObject:message forKey:@"gift_card_info"];
                        [self stopRedeeming:dictMut];
                    }
                    else
                    {
                        NSString *str = [NSString stringWithFormat:@"Your redemption process via our automated redemption system was unsuccessful. Please contact us at redeem@kangaroosuperheroes.com and also quote your Redeem ID :%@ for assistance.",[[dict objectForKey:@"redeem_info"] objectForKey:@"redeem_id"]];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps! Something went wrong!" message:str delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        //                    NSMutableDictionary *dictMut = [NSMutableDictionary dictionaryWithDictionary:dictParameters];
                        //                    [dictMut setObject:@"0" forKey:@"redeem_mode"];
                        //                    [self stopRedeeming:dictMut];
                    }
                    AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app removingActivityView];
                }];
            }
            else
            {
                NSString *scoreToReduce = [NSString stringWithFormat:@"-%@",[[dict objectForKey:@"redeem_info"] objectForKey:@"redeem_score"]];
                [AdModel updateScore:strUpdatedScore];
                NSDictionary *dictUpdate = [NSDictionary dictionaryWithObjectsAndKeys:scoreToReduce,@"score",[dictParameters objectForKey:@"email_id"],@"email", nil];
                [self updatePoints:dictUpdate];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"response_message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app removingActivityView];
                [app removingView];

            }
            
        }
        else
        {
            AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app removingActivityView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"response_message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        AppDelegate *app =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app removingActivityView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Something went wrong. Check your internet connection and try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

    }];
}


-(void)stopRedeeming:(NSDictionary *)dictParameters
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kbaseurl,kredeemGift];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:dictParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSLog(@"%@",json);
        NSDictionary *dict = json;
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}



-(void)settingScore
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kbaseurl,ksettingScore];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self getUniqueDeviceIdentifierAsString],@"player_id",[AdModel getScore],@"score", nil];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSLog(@"%@",json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)gettingScore
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kbaseurl,kgettingScore];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self getUniqueDeviceIdentifierAsString],@"player_id", nil];
    managerObject = [AFHTTPRequestOperationManager manager];
    managerObject.responseSerializer = [AFHTTPResponseSerializer serializer];
    [managerObject.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"] ;
    [managerObject POST:urlstr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        NSLog(@"%@",json);
        adObject.strPlayScore = [[json objectForKey:@"player_data"] objectForKey:@"score"];
        adObject.strPlayerID = [[json objectForKey:@"player_data"] objectForKey:@"player_id"];
        adObject.strPlayerName = [[json objectForKey:@"player_data"] objectForKey:@"player_name"];
        [self synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);

    }];
}

@end
