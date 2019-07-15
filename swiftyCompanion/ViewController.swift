//
//  ViewController.swift
//  swiftyCompanion
//
//  Created by Yaroslava HLIBOCHKO on 7/10/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    let myUID = "2323d65a5b4242f4c9ab5941ea6d46840ef952602e4ab6c468c79779031042a0"
    let secret = "ff8a1eb9fda2ed3494053693867199fd481885acc89cdd4b3b84a6d975a60a9d"
    let redirectUri = "swiftyCompanion://swiftyCompanion"
    let url = "https://api.intra.42.fr"
    let fuulUrl = "https://api.intra.42.fr/oauth/authorize?client_id=2323d65a5b4242f4c9ab5941ea6d46840ef952602e4ab6c468c79779031042a0&redirect_uri=swiftyCompanion%3A%2F%2FswiftyCompanion&response_type=code"
    var token: String?
    var json: JSON?
    var xlogin: String?
    var user = [String: String]()
    var imgCoolition: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if token == nil {
            getToken()
        }
    }

    @IBAction func searchButton(_ sender: UIButton) {
        xlogin = loginTextField.text
        xlogin = xlogin!.trimmingCharacters(in: .whitespacesAndNewlines)
        if xlogin?.isEmpty == false {
            coolition()
            findLogin()
        } else {
            makeAlert(title: "Invalid Login", message: "Please enter current Login")
        }
    }
    
    func getToken() {
        Alamofire.request("https://api.intra.42.fr/oauth/token", method: .post, parameters: ["grant_type" : "client_credentials", "client_id" : myUID, "client_secret" : secret]).validate().responseJSON {response in
            switch response.result {
            case .success:
                print("success")
                self.json = JSON(response.value!)
                self.token = self.json!["access_token"].string
            case .failure:
                print("failure")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let evc = segue.destination as? SecondViewController {
            if (segue.identifier == "userInformation" && sender != nil) {
                evc.coolition = self.imgCoolition
                evc.info = sender as? JSON
            }
        }
    }
    
    func findLogin () {
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(self.token!)"]
        Alamofire.request(url + "/v2/users/" + self.xlogin!, method: .get, headers: headers).responseJSON {response in
            switch response.result {
            case .success(_):
                self.json = JSON(response.value!)
                if (self.json?.isEmpty)! {
                    print("bad user")
                    self.makeAlert(title: "Invalid Login", message: "Please enter current Login")
                } else {
                    self.performSegue(withIdentifier: "userInformation", sender: self.json)
                }
            case .failure(_):
                self.makeAlert(title: "Invalid Login", message: "Please enter current Login")
            }
        }
    }
    
    func coolition(){
        let headers: HTTPHeaders = ["Authorization" : "Bearer \(self.token!)"]
        Alamofire.request(url + "/v2/users/" + self.xlogin! + "/coalitions", method: .get, headers: headers).responseJSON {response in
            switch response.result {
            case .success(_):
                self.json = JSON(response.value!)
                if (self.json?.isEmpty)! {
                    self.makeAlert(title: "Invalid Login", message: "Please enter current Login")
                } else {
                    self.imgCoolition = self.json![0]["name"].string
                }
            case .failure(_):
                print("ERROR IN COOLITIONS")
            }
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
}

