//
//  GasStationViewModel.swift
//  GasStationInfo
//
//  Created by Dmitro Kryzhanovsky on 07.09.2023.
//

import Foundation
import CoreLocation
import MapKit

struct GasStationViewModel {
    
    var gasStation: MKMapItem
    var distanceToUser: CLLocationDistance?
    
    init(gasStation: MKMapItem, userLocation: CLLocationCoordinate2D? = nil) {
        self.gasStation = gasStation
        
        if let userLocation = userLocation {
            let userCoordinate = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let endCoordinate = CLLocation(latitude: gasStation.placemark.coordinate.latitude, longitude: gasStation.placemark.coordinate.longitude)
            let distance = userCoordinate.distance(from: endCoordinate)
            
            self.distanceToUser = round(distance/10) / 100.0
        } else {
            self.distanceToUser = nil
        }
    }
    
}
