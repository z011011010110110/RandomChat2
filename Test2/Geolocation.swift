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
            Button(viewModel.distanceString, action: {
                viewModel.privacyCheck()
//                viewModel.getDistanceFromPartner(person: Person(name:"", imgString:"", geopoint:Geopoint(latitude:30.462067, longitude:-97.688533)))

                viewModel.saveLocation()
            })
            .onAppear {
                viewModel.privacyCheck()
            }
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                //.ignoresSafeArea()
                .onAppear {
                    viewModel.privacyCheck()
                }
        }

    }
}



struct Geolocation_Previews: PreviewProvider {
    static var previews: some View {
        Geolocation()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @StateObject var chatData:CoreDataViewModel = CoreDataViewModel()
    var locationManager: CLLocationManager?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:30.462067, longitude: -97.688533), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @Published var distanceFromHome:Double = 0
    @Published var distanceString = "Tap to see distance from each other"
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
    ///Returns distance between 2 points in meters
    func distanceInmBetweenEarthCoordinates(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {

        let earthRadiusKm: Double = 6371

        let dLat = degreesToRadians(degrees: lat2 - lat1)
        let dLon = degreesToRadians(degrees: lon2 - lon1)

        let lat1 = degreesToRadians(degrees: lat1)
        let lat2 = degreesToRadians(degrees: lat2)

        let a = sin(dLat/2) * sin(dLat/2) +
        sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c * 1000
    }

    ///Distance from chatting partner. So far, it only calculates distance from Home, not partner's location.
//    func getDistanceFromPartner(person:Person){
//        
//        ///Rounds to 1 decimal place
//        distanceFromHome = Double(round(10 * distanceInmBetweenEarthCoordinates(lat1:person.geopoint.latitude,lon1:person.geopoint.longitude,lat2:region.center.latitude,lon2:region.center.longitude)) / 10)
//        
//        distanceString = "You are \(distanceFromHome) meters from \(person.name)"
//    }
    
    ///Distance from chatting partner. So far, it only calculates distance from Home, not partner's location.
    func getDistanceFromEachOther(person1:Person, person2:Person){
        
        ///Rounds to 1 decimal place
        distanceFromHome = Double(round(10 * distanceInmBetweenEarthCoordinates(lat1:person1.geopoint.latitude,lon1:person1.geopoint.longitude,lat2:person2.geopoint.latitude,lon2:person2.geopoint.longitude)) / 10)
        distanceString = "You are \(distanceFromHome) meters from each other"
    }
    
    func saveLocation(){
        privacyCheck()
        chatData.saveLocation(lat: region.center.latitude, lon: region.center.longitude)
    }
    

    
    func privacyCheck(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyBest
            locationManager!.delegate = self
            
            
            locationManager?.distanceFilter = 0.5
            //locationManager!.allowsBackgroundLocationUpdates = true0
            locationManager?.startUpdatingLocation()
            
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
