//
//  AmapView.swift
//  flutter_plugin_map
//
//  Created by 孙红 on 2022/3/8.
//

import Foundation
import UIKit

public class AmapView: NSObject, FlutterPlatformView {
    var params: Dictionary<String, Any?>
        
    let messenger: FlutterBinaryMessenger
        
    var mapView: MAMapView
    
    var search: AMapSearchAPI
    
    var route: AMapRoute?
    
    var polylines = [Any]()

    var markOptions = [MarkerOption]()
    
        
    private var _view: UIView
        
    init(messenger: FlutterBinaryMessenger, params: Dictionary<String, Any?>) {
        _view = UIView()
        self.params = params
        self.messenger = messenger
        
        // 更新用户授权高德SDK隐私协议状态. 注意：必须在MAMapView实例化之前调用
        MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        
        self.mapView = MAMapView()
        self.params = params
        mapView = MAMapView(frame: _view.bounds)
        search = AMapSearchAPI()
   
    
        super.init()
        search.delegate = self
        initMapView()
        _view.addSubview(mapView)
    }
        
    public func view() -> UIView {
        return self._view
    }
        
    func initMapView() {
    
        self.mapView.delegate = self;
        AMapServices.shared().enableHTTPS = true
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .followWithHeading
        self.mapView.mapType = MAMapType.standard
        self.mapView.isRotateEnabled = false
        requestLocation()
    }
        
    func setMapType(val mapType: Int) -> MAMapType? {
        return MAMapType(rawValue: mapType - 1)
    }

}


extension AmapView {
    public func requestLocation() {
        if (self.params["options"] == nil) {
            return
        }
        let options = self.params["options"] as? [Dictionary<String, Any>]
        if (options == nil || options?.count == 0) {
            return
        }
        
        for item in options! {
            guard let latitude = item["latitude"] as? Double, let longitude = item["longitude"] as? Double else {
                continue
            }
            let markOption = MarkerOption(title: item["title"] as? String ?? "", latitude: latitude, longitude: longitude)
            markOptions.append(markOption)
        }
        dealSearchPotins()
    }
    
    private func dealSearchPotins() {
        let row = markOptions.count / 8 + 1
        for i in 0..<row {
            let start = i * 7
            var end = start + 7
            if (end > markOptions.count) {
                end = markOptions.count - 1
            }
            
            let pointAnnotationStart = addAnnotationToMapView(markOptions[start])
            let pointAnnotationEnd = addAnnotationToMapView(markOptions[end])

            mapView.showAnnotations([pointAnnotationStart, pointAnnotationEnd], edgePadding: UIEdgeInsets(top: 70, left: 20, bottom: 80, right: 20), animated: true)
            
            // 发起路线规划
            
            let request = AMapDrivingRouteSearchRequest()
            request.origin = AMapGeoPoint.location(withLatitude: CGFloat(pointAnnotationStart.coordinate.latitude), longitude: CGFloat(pointAnnotationStart.coordinate.longitude))
            request.destination = AMapGeoPoint.location(withLatitude: CGFloat(pointAnnotationEnd.coordinate.latitude), longitude: CGFloat(pointAnnotationEnd.coordinate.longitude))
            let wayStart = start + 1
            let wayEnd = end - 1
            // 途径点添加标注
            if (wayStart <= wayEnd) {
                var arr = [AMapGeoPoint]()
                for j in wayStart...wayEnd {
                    let markOption = markOptions[j]
                    let markGeoPoint = AMapGeoPoint.location(withLatitude: markOption.latitude, longitude: markOption.longitude)
                    if (markGeoPoint != nil) {
                        arr.append(markGeoPoint!)
                        let _ = addAnnotationToMapView(markOptions[j])
                    }
                }
                request.waypoints = arr
            }
            
            request.requireExtension = true
            
            search.aMapDrivingRouteSearch(request)
        }
    }
    
    private func addAnnotationToMapView(_ markerOption: MarkerOption) -> MAPointAnnotation {
       
        let pointAnnotation = MAPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(markerOption.latitude, markerOption.longitude);
        pointAnnotation.title = markerOption.title
        self.mapView.addAnnotation(pointAnnotation)
        return pointAnnotation
    }
    
}

extension AmapView : MAMapViewDelegate {

    public func mapViewRequireLocationAuth(_ locationManager: CLLocationManager) -> Void {
        locationManager.requestAlwaysAuthorization()
    }
    
    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {

        let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
        renderer.lineWidth = params["lineWidth"] as? CGFloat ?? 8;
        renderer.strokeColor = UIColor.blue;
        renderer.lineJoinType = kMALineJoinRound;
        renderer.lineCapType = kMALineCapRound;
        
        return renderer
    }
    
    public func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isKind(of: MAUserLocation.self)) {
            let userReuseIndentifier = "userReuseIndentifier"
            var userAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: userReuseIndentifier)
            if (userAnnotationView == nil) {
                userAnnotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: userReuseIndentifier)
            }
            userAnnotationView?.image = UIImage(named: "ico_map_local")
            return userAnnotationView
        }
    
        if (annotation.isKind(of: MAPointAnnotation.self)) {
            let pointReuseIndentifier = "pointReuseIndentifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndentifier)
            if (annotationView == nil) {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndentifier)
            }
            let showStartAndEndPotin = params["showStartAndEndIcon"] as! Bool
            let showWayPoints = params["showWayPointsIcon"] as! Bool
        
            if (annotation.title == "装货地") {
                if (showStartAndEndPotin) {
                    annotationView!.centerOffset = CGPoint(x: 0, y: -20)
                    annotationView!.image = UIImage(named: "ico_guiji_zhuang")
                }
                
            } else if (annotation.title == "卸货地") {
                if (showStartAndEndPotin) {
                    annotationView!.centerOffset = CGPoint(x: 0, y: -20)
                    annotationView!.image = UIImage(named: "ico_guiji_xie")
                }
            } else {
                if (showWayPoints) {
                    annotationView!.image = UIImage(named: "ico_guiji_truck")
                }
            }
            return annotationView
        }
        return nil
    }

}

extension AmapView : AMapSearchDelegate {
    
    public func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        if (response.route == nil) {
            return
        }
     
        if response.count > 0 {
            //解析response获取路径信息
            self.route = response.route;
            
            let path = response.route.paths[0];
       
            
            for (_, step) in path.steps.enumerated() {
                
                let stepPolyline = CommonUtility.tagPolyline(forCoordinateString: step.polyline)
                if (stepPolyline == nil) {
                    return
                }
                polylines.append(stepPolyline as Any)
            }
            mapView.removeOverlays(polylines)
            
           
        }
        self.mapView.addOverlays(polylines)
        
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(String(describing: error))")
    }
    
}

public struct MarkerOption {
    var title: String
    var latitude: Double
    var longitude: Double
}



