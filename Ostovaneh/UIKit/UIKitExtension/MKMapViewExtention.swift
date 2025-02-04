//
//  MKMapViewExtention.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/27/1400 AP.
//

import Foundation
import MapKit

public extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        setRegion(coordinateRegion, animated: true)
        
        let mapCamera = MKMapCamera(lookingAtCenter: coordinateRegion.center, fromDistance: regionRadius, pitch: 0, heading: 0)
        
        setCamera(mapCamera, animated: true)
    }
}
