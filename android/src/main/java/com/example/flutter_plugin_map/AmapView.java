package com.example.flutter_plugin_map;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.amap.api.location.AMapLocationClient;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.LocationSource;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.LatLngBounds;
import com.amap.api.maps.model.MarkerOptions;
import com.amap.api.maps.model.MyLocationStyle;
import com.amap.api.maps.model.PolylineOptions;
import com.amap.api.services.core.AMapException;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.route.BusRouteResult;
import com.amap.api.services.route.DrivePath;
import com.amap.api.services.route.DriveRouteResult;
import com.amap.api.services.route.DriveStep;
import com.amap.api.services.route.RideRouteResult;
import com.amap.api.services.route.RouteSearch;
import com.amap.api.services.route.RouteSearch.DriveRouteQuery;
import com.amap.api.services.route.WalkRouteResult;
import com.amap.api.services.route.RouteSearch.FromAndTo;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class AmapView implements PlatformView, MethodChannel.MethodCallHandler, RouteSearch.OnRouteSearchListener {

    MapView mapView;

    AMap aMap;

    RouteSearch routeSearch;

    LocationSource.OnLocationChangedListener mListener;

    private MethodChannel methodChannel;

    private Context context;

    private static final String TAG = "AmapView";

    private Map<String, Object> initParams;

    private List<MarkerOptionModel> markerOptionsList;

    private DriveRouteResult _driveRouteResult;

    public AmapView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
        Log.d(TAG, params.toString());
        methodChannel = new MethodChannel(messenger, "flutter_plugin_map");
        methodChannel.setMethodCallHandler(this);
        initParams = params;
        //初始化定位
        AMapLocationClient.updatePrivacyShow(context, true, true);
        AMapLocationClient.updatePrivacyAgree(context, true);

        try {
            routeSearch = new RouteSearch(context);
            routeSearch.setRouteSearchListener(this);
        } catch (AMapException e) {

        }
        markerOptionsList = new LinkedList<>();

        createMap(context);
        initMapOptions();
        mapView.onResume();
        this.context = context;
        dealParams();
    }

    private void dealParams() {
        if (initParams.get("options") == null) {
            return;
        }
        List<Map<String, Object>> options = (List<Map<String, Object>>)initParams.get("options");
        for (Map<String, Object> item : options) {
            MarkerOptionModel markerOption = new MarkerOptionModel();
            markerOption.title = (String) item.get("title");
            markerOption.latitude = (double) item.get("latitude");
            markerOption.longitude = (double) item.get("longitude");
            markerOptionsList.add(markerOption);
        }

        dealSearchPoints();
    }

    private void dealSearchPoints() {
        int row = markerOptionsList.size() / 8 + 1;
        for (int i = 0; i < row; i++) {
            int start = i * 7;
            int end = start + 7;
            if (end > markerOptionsList.size() - 1) {
                end = markerOptionsList.size() - 1;
            }
            addAnnotationToMapView(markerOptionsList.get(start));
            addAnnotationToMapView(markerOptionsList.get(end));

            LatLonPoint startPoint = new LatLonPoint(markerOptionsList.get(start).latitude, markerOptionsList.get(start).longitude);
            LatLonPoint endPoint = new LatLonPoint(markerOptionsList.get(end).latitude, markerOptionsList.get(end).longitude);
            FromAndTo fromAndTo = new FromAndTo(startPoint, endPoint);

            int wayStart = start + 1;
            int wayEnd = end - 1;
            List<LatLonPoint> wayPointArr = new LinkedList<>();

            if (wayStart <= wayEnd) {
                for (int j = wayStart; j < wayEnd; j++) {
                    MarkerOptionModel optionModel = markerOptionsList.get(j);
                    LatLonPoint point = new LatLonPoint(optionModel.latitude, optionModel.longitude);
                    wayPointArr.add(point);
                    addAnnotationToMapView(optionModel);
                }

            }
            DriveRouteQuery driveRouteQuery = new DriveRouteQuery(fromAndTo, RouteSearch.DRIVING_SINGLE_DEFAULT, null, null, "");

            routeSearch.calculateDriveRouteAsyn(driveRouteQuery);
        }
    }

    private void addAnnotationToMapView(MarkerOptionModel markerOptionModel) {
        MarkerOptions markerOption = new MarkerOptions();
        markerOption.position(new LatLng(markerOptionModel.latitude, markerOptionModel.longitude));
        markerOption.title(markerOptionModel.title);
        markerOption.draggable(false);
        markerOption.setGps(true);
        aMap.addMarker(markerOption);
    }

    @Override
    public View getView() {
        return mapView;
    }

    @Override
    public void dispose() {
        mapView.onDestroy();
    }

    private void createMap(Context context) {
        mapView = new MapView(context);
        mapView.onCreate(new Bundle());
        aMap = mapView.getMap();
    }

    private void initMapOptions() {
        Log.d(TAG, initParams.toString());
        aMap.moveCamera(CameraUpdateFactory.zoomTo(Float.parseFloat(initParams.get("zoomLevel").toString())));
        aMap.getUiSettings().setMyLocationButtonEnabled(true);
        MyLocationStyle myLocationStyle = new MyLocationStyle();
        myLocationStyle.interval((int)initParams.get("interval"));
        myLocationStyle.strokeWidth(1f);
        myLocationStyle.strokeColor(Color.parseColor("#8052A3FF"));
        myLocationStyle.radiusFillColor(Color.parseColor("#3052A3FF"));
        myLocationStyle.showMyLocation(true);
//        myLocationStyle.myLocationIcon(BitmapDescriptorFactory.fromResource(R.drawable.gpsbiaozhudianguanli));
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        aMap.setMyLocationStyle(myLocationStyle);
        aMap.setMyLocationEnabled(true);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("addMarkers")) {
            if (call.arguments != null) {
                Map<String, Object> datas = (Map<String, Object>) call.arguments;
                showMarker(datas);
                result.success("suc");
            }
        }
    }

    private void showMarker(Map<String, Object> data) {
        MarkerOptions markerOption = new MarkerOptions();
        markerOption.position(new LatLng((double) data.get("latitude"), (double) data.get("longitude")));
        markerOption.title((String) data.get("title"));
        markerOption.draggable(false);
//        markerOption.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory
//                .decodeResource(this.context.getResources(), R.drawable.icon_biaozhu)));
        markerOption.setGps(true);
        aMap.addMarker(markerOption);
    }

    @Override
    public void onBusRouteSearched(BusRouteResult busRouteResult, int i) {

    }

    @Override
    public void onDriveRouteSearched(DriveRouteResult driveRouteResult, int i) {
        if (i == 1000) {
            if (driveRouteResult != null && driveRouteResult.getPaths() != null
                    && driveRouteResult.getPaths().size() > 0) {
                _driveRouteResult = driveRouteResult;
                DrivePath drivePath = driveRouteResult.getPaths().get(0);
                if (drivePath == null) {
                    return;
                }
                List<LatLng> latLngs = new LinkedList<>();
                for (int j = 0; j < drivePath.getSteps().size(); j++) {
                    DriveStep step = drivePath.getSteps().get(j);
                    for (LatLonPoint mLatLonPoint: step.getPolyline()) {
                        latLngs.add(new LatLng(mLatLonPoint.getLatitude(), mLatLonPoint.getLongitude()));
                    }
                }
                aMap.clear();
                aMap.addPolyline(new PolylineOptions().addAll(latLngs).width(30).color(Color.BLUE));

                //显示完整包含所有marker地图路线
                LatLngBounds.Builder builder = new LatLngBounds.Builder();
                for (int K = 0; K < latLngs.size(); K++) {
                    builder.include(latLngs.get(i));
                }
                //显示全部marker,第二个参数是四周留空宽度
                aMap.moveCamera(CameraUpdateFactory.newLatLngBounds(builder.build(),200));
            }
        }
    }

    @Override
    public void onWalkRouteSearched(WalkRouteResult walkRouteResult, int i) {

    }

    @Override
    public void onRideRouteSearched(RideRouteResult rideRouteResult, int i) {

    }
}

class MarkerOptionModel {
    String title;
    double latitude;
    double longitude;
}

