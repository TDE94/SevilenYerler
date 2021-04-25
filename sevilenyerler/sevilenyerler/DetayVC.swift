//
//  DetayVC.swift
//  sevilenyerler
//
//  Created by Taylan Erdogan on 25.04.2021.
//

import UIKit
import CoreData

class DetayVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var idDizi = [UUID()]
    var yerDizi = [String]()
    var secilenYer = ""
    var secilenId: UUID?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        verileriAl()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ekleSayfasi))

       
    }
  
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yerDizi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = yerDizi[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
        
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuid = idDizi[indexPath.row].uuidString
            fetchReq.predicate = NSPredicate(format: "id=%@", uuid)
            fetchReq.returnsObjectsAsFaults = false
        do {
            let sonuclar = try context.fetch(fetchReq)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let id  = sonuc.value(forKey: "id") as? UUID{
                        if id == idDizi[indexPath.row]{
                            context.delete(sonuc)
                            idDizi.remove(at: indexPath.row)
                            yerDizi.remove(at: indexPath.row)
                            
                            self.tableView.reloadData()
                            
                            do {
                                try context.save()
                            } catch{
                                print("Hata")
                            }
                            
                        }
                    }
                    
                }
            }
        } catch{
            print("Hata")
        }
        }
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYer = yerDizi[indexPath.row]
        secilenId = idDizi[indexPath.row]
        performSegue(withIdentifier: "toDetayVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetayVC"{
            let detayVC = segue.destination as! ViewController
            detayVC.alinanYer = secilenYer
            detayVC.alinanId = secilenId
            
        }
    }
    
    
    
    
    
    
    @objc func verileriAl(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        fetchReq.returnsObjectsAsFaults = false
        
        do {
           let sonuclar  =  try context.fetch(fetchReq)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let yerAdi = sonuc.value(forKey: "yer") as? String{
                        yerDizi.append(yerAdi)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizi.append(id)
                    }
                    tableView.reloadData()
                }
                
            }
        } catch  {
            print("Hata Bulundu")
        }
        
        
    }
    @objc func ekleSayfasi(){
        secilenYer = ""
        performSegue(withIdentifier: "toDetayVC", sender: nil)
    }
   

}
