//
//  ViewController.swift
//  sevilenyerler
//
//  Created by Taylan Erdogan on 24.04.2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var kaydetButon: UIButton!
    @IBOutlet weak var yerTf: UITextField!
    @IBOutlet weak var notTf: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var alinanYer = ""
    var alinanId : UUID?
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    var locationManager = CLLocationManager()
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if alinanYer != ""{
            kaydetButon.isHidden = true
           
            if let uuidString = alinanId?.uuidString{
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let context = delegate.persistentContainer.viewContext
                let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchReq.predicate = NSPredicate(format: "id=%@", uuidString)
                fetchReq.returnsObjectsAsFaults = false
                do {
                   let sonuclar =  try context.fetch(fetchReq)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let yer = sonuc.value(forKey: "yer") as? String{
                                annotationTitle = yer
                                if let not  = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle = not
                                    if let longitude = sonuc.value(forKeyPath: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        if let latitude = sonuc.value(forKeyPath: "latitude") as? Double {
                                            annotationLatitude = latitude
          
                                        }
                                    }
                                }

                            }
                          
                           
                            
                        }
                        
                                                          let annotation = MKPointAnnotation()
                                                          let coordinate = CLLocationCoordinate2D(latitude:annotationLatitude,longitude: annotationLongitude)
                                                          annotation.title = annotationTitle
                                                          annotation.subtitle = annotationSubtitle
                                                          annotation.coordinate = coordinate
                                                          mapView.addAnnotation(annotation)
                                                          locationManager.stopUpdatingLocation()
                                                          let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                                          let region = MKCoordinateRegion(center: coordinate, span: span)
                                                          mapView.setRegion(region, animated: true)
                                                          annotationSubtitle = notTf.text!
                                                          annotationTitle = yerTf.text!
                    }
                } catch  {
                    print("Hata")
                }
            }
        }else{
            kaydetButon.isHidden = false
            kaydetButon.isEnabled = false
            yerTf.text = ""
            notTf.text = ""
        }
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        
   
    }
    

    
    
    // Konum Seçimi için gereken kodlar
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
            let dokunulanNokta = gestureRecognizer.location(in: self.mapView)
            let dokunulanKordinat = self.mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKordinat
            secilenLatitude = dokunulanKordinat.latitude
            secilenLongitude = dokunulanKordinat.longitude
            annotation.title = yerTf.text
            annotation.subtitle = notTf.text
            self.mapView.addAnnotation(annotation)
            
        }
        kaydetButon.isEnabled = true
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if alinanYer == "" {
            let locations = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: locations, span: span)
            mapView.setRegion(region, animated: true)
            
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reduceid = "benimanot"
        var pinview = mapView.dequeueReusableAnnotationView(withIdentifier: reduceid)
        
        if pinview == nil {
            pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reduceid)
            pinview?.canShowCallout = true
            pinview?.tintColor = .blue
            let button = UIButton(type: .detailDisclosure)
            pinview?.rightCalloutAccessoryView = button
        } else {
            pinview?.annotation = annotation
        }
        
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if alinanYer != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placeMarkerDizi, hata) in
                if let placemarks = placeMarkerDizi{
                    if placemarks.count > 0 {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: options)
                    }
                }
                
            }
        }
    }

    
    
    
 
    
    @IBAction func kaydetButon(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(notTf.text, forKey: "not")
        yeniYer.setValue(yerTf.text, forKey: "yer")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Kayıt Tamamdır")
            notTf.text = ""
            yerTf.text = ""
            
        } catch  {
            print("Hata var")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    

}

