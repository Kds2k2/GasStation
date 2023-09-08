//
//  ViewController.swift
//  GasStationInfo
//
//  Created by Dmitro Kryzhanovsky on 06.09.2023.
//

import UIKit
import CoreLocation
import MapKit
import SafariServices

class ViewController: UIViewController {

    private var userLocation: CLLocationCoordinate2D? = nil
    
    private var items = [GasStationViewModel]()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .white
        table.dataSource = self
        table.delegate = self
        table.register(GasStationTableViewCell.self, forCellReuseIdentifier: GasStationTableViewCell.identifier)
        return table
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            mapView.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.5)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
        ])
        
        getUserLocation()
    }
    
    private func getUserLocation() {
        LocationService.shared.locationUpdated = { location in
            self.userLocation = location
            
            self.fetchPlaces(location: location)
            
            let searchSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let searchRegion = MKCoordinateRegion(center: location, span: searchSpan)
            self.mapView.setRegion(searchRegion, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Your Location"
            self.mapView.addAnnotation(annotation)
            self.mapView.centerCoordinate = location
        }
    }
    
    private func fetchPlaces(location: CLLocationCoordinate2D) {
        let searchSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let searchRegion = MKCoordinateRegion(center: location, span: searchSpan)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.naturalLanguageQuery = "Gas Station"
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let mapItems = response?.mapItems else {
                return
            }
            
            DispatchQueue.main.async {
                var items = [GasStationViewModel]()
                mapItems.forEach {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = $0.placemark.coordinate
                    annotation.title = $0.name
                    self.mapView.addAnnotation(annotation)
                    
                    items.append(GasStationViewModel(gasStation: $0, userLocation: self.userLocation))
                }
                self.items = items.sorted { $0.distanceToUser! < $1.distanceToUser! }
                self.tableView.reloadData()
            }
            
            let _ = mapItems.map { $0.name }
        }
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }
                
                //for getting just one route
                if let route = unwrappedResponse.routes.first {
                    //show on map
                    self.mapView.addOverlay(route.polyline)
                    //set the map area to show the route
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                }

                //if you want to show multiple routes then you can get all routes in a loop in the following statement
                //for route in unwrappedResponse.routes {}
            }
        }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GasStationTableViewCell.identifier, for: indexPath) as! GasStationTableViewCell
        if userLocation != nil {
            cell.model = items[indexPath.row]
        } else {
            print("User location is nil")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        //self.mapView.centerCoordinate = item.placemark.coordinate
        if let userLocation = userLocation {
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            showRouteOnMap(pickupCoordinate: userLocation, destinationCoordinate: item.gasStation.placemark.coordinate)
        }
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = item.placemark.coordinate
//        annotation.title = item.name ?? "No name found"
//        self.mapView.addAnnotation(annotation)
        
//        items[indexPath.row].openInMaps()
//        guard let url = items[indexPath.row].url else { return }
//        let vc = SFSafariViewController(url: url)
//        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         let renderer = MKPolylineRenderer(overlay: overlay)
         renderer.strokeColor = UIColor.systemBlue
         renderer.lineWidth = 5.0
         return renderer
    }
    
}
