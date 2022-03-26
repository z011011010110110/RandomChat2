//
//  Geolocation.swift
//  Test2
//
//  Created by Hyunbin Joo on 3/25/22.
//

import SwiftUI
import MapKit




struct Geolocation: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack{
            Text("\(viewModel.region.center.longitude )")
            Text("\(viewModel.region.center.latitude )")
            Button("Button", action: {
                viewModel.privacyCheck()
            })
            .onAppear {
                viewModel.privacyCheck()
            }
        }
//        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
//            .ignoresSafeArea()
//            .onAppear {
//                viewModel.privacyCheck()
//            }
    }
}



struct Geolocation_Previews: PreviewProvider {
    static var previews: some View {
        Geolocation()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @Published var lon:Double = 0
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:30.462, longitude: -98.688), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    
    
    func privacyCheck(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager!.delegate = self
            print("Location Service Enabled")
        }
        else{
            print("Location Service Disabled")
        }
    }

    private func checkAuthorization(){
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Resricted")
        case .denied:
            print("Denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        @unknown default:
            break
        }

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
    
    
    
}
