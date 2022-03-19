//
//  MapView.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/23/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView{
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 34, longitude: -116)
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: coordinate, span: span )
        uiView.setRegion(region, animated: true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
