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
        
    private var _view: UIView
        
    init(messenger: FlutterBinaryMessenger, params: Dictionary<String, Any?>) {
        _view = UIView()
            self.params = params
        self.messenger = messenger
        MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        self.mapView = MAMapView()
        self.params = params
        mapView = MAMapView(frame: _view.bounds)
        super.init()
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
    }
        
    func setMapType(val mapType: Int) -> MAMapType? {
        return MAMapType(rawValue: mapType - 1)
    }

}

extension AmapView : MAMapViewDelegate {

    public func mapViewRequireLocationAuth(_ locationManager: CLLocationManager) -> Void {
        locationManager.requestAlwaysAuthorization()
    }

}


