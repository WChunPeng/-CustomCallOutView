//
//  ViewController.m
//  CustomCallOutView
//
//  Created by admin on 2017/3/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import "XCUCallOutMapAnnotation.h"
#import "XCUCustomAnnotationCalloutView.h"
#import "XCUCustomContentView.h"

@interface ViewController ()<AMapLocationManagerDelegate,MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet MAMapView *myMapView;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) XCUCallOutMapAnnotation *mySelfpointAnnotaiton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configLocationManager];
 
    self.myMapView.delegate = self;
    
}

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self startSerialLocation];
}

#pragma mark-------------地图定位相关--------------
- (void)startSerialLocation
{
    //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位错误
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //定位结果
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            //将获得的所有信息显示到label上
            NSString *placeName = placemark.name;
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            
            
            self.mySelfpointAnnotaiton = [[XCUCallOutMapAnnotation alloc] init];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"我自己定义的文字",@"device",placeName,@"adress",[self getNowTimeString],@"time",nil];
            
            self.mySelfpointAnnotaiton.latitude =  location.coordinate.latitude;
            self.mySelfpointAnnotaiton.longitude =  location.coordinate.longitude;
            self.mySelfpointAnnotaiton.locationInfo = dict;
            [self.myMapView addAnnotation:self.mySelfpointAnnotaiton];
            [self.myMapView setCenterCoordinate:self.mySelfpointAnnotaiton.coordinate animated:YES];
            [self.myMapView setZoomLevel:17.5 animated:YES];
            
            [self stopSerialLocation];

        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    

}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation;
{
    if ([annotation isKindOfClass:[XCUCallOutMapAnnotation class]]){

        //此时annotation就是我们calloutview的annotation
        XCUCallOutMapAnnotation *ann = (XCUCallOutMapAnnotation *)annotation;

        //如果可以重用
        XCUCustomAnnotationCalloutView *calloutannotationview = (XCUCustomAnnotationCalloutView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"calloutview"];

        //否则创建新的calloutView
        if (!calloutannotationview) {
        calloutannotationview = [[XCUCustomAnnotationCalloutView alloc] initWithAnnotation:annotation reuseIdentifier:@"calloutview"] ;

        XCUCustomContentView *cell = [[[NSBundle mainBundle] loadNibNamed:@"XCUCustomContentView" owner:self options:nil] objectAtIndex:0];

        [calloutannotationview.contentView addSubview:cell];
        calloutannotationview.infoView = cell;
        }
        calloutannotationview.centerOffset = CGPointMake(0, -80);
        //开始设置添加marker时的赋值
        calloutannotationview.infoView.deviceLable.text = [ann.locationInfo objectForKey:@"device"];
        calloutannotationview.infoView.adressLable.text = [ann.locationInfo objectForKey:@"adress"];
        calloutannotationview.infoView.timeLable.text =[ann.locationInfo objectForKey:@"time"];

        return calloutannotationview;

    }
    
    return nil;
    
}

- (NSString *)getNowTimeString
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
