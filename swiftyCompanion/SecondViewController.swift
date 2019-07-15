//
//  SecondViewController.swift
//  swiftyCompanion
//
//  Created by Yaroslava HLIBOCHKO on 7/10/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit
import SwiftyJSON

class SecondViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var usrCoolition: UIImageView!
    @IBOutlet weak var correctionPoints: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var progressLevelView: UIProgressView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var locationPlace: UILabel!
    var coolition: String?
    var skillsValuesArray: [Float] = []
    var skillsTextArray: [String] = []
    var projectsArray: [(String, Int, Bool)] = []
    var info: JSON?
    
    @IBOutlet weak var skillTableView: UITableView!
    @IBOutlet weak var projectTableView: UITableView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        skillTableView.delegate = self
        skillTableView.dataSource = self
        projectTableView.delegate = self
        projectTableView.dataSource = self
        
        getInfo()
        getSkills()
        getProjects()
    }
  
    func getInfo() {
        switch coolition {
        case "The Alliance":
            usrCoolition.image = UIImage(imageLiteralResourceName: "alliance_background")
        case "The Hive" :
            usrCoolition.image = UIImage(imageLiteralResourceName: "hive_background")
        case "The Empire":
            usrCoolition.image = UIImage(imageLiteralResourceName: "empire_background")
        case "the Union":
            usrCoolition.image = UIImage(imageLiteralResourceName: "union_background")
        default:
            break
        }
        displayName.text = self.info!["displayname"].string
        correctionPoints.text = "points: " + "\(self.info!["correction_point"].int!)"
        wallet.text = "wallet: " + "\(self.info!["wallet"].int!)"
        email.text = self.info!["email"].string
        let url = URL(string: self.info!["image_url"].string!)
        if let data = try? Data(contentsOf: url!) {
            DispatchQueue.main.async {
                self.photo.layer.borderWidth =  3
                self.photo.layer.masksToBounds = false
                self.photo.layer.borderColor = UIColor.white.cgColor
                self.photo.layer.cornerRadius = self.photo.frame.height/2
                self.photo.clipsToBounds = true
                self.photo.image = UIImage(data: data)
                self.photo.contentMode = .scaleAspectFill
            }
        } else {
            print("error")
        }
        phone.text = self.info!["phone"].string
        if phone.text == nil || phone.text == "" {
            phone.text = "--"
        }
        if let checkLevel = self.info!["cursus_users"][0]["level"].float {
            level.text = "Level: \(checkLevel)%"
            progressLevelView.progress = checkLevel / 21
        }
        login.text = self.info!["cursus_users"][0]["user"]["login"].string
        if self.info!["location"].string == nil || self.info!["location"].string == "" {
            location.text = "Unavailable"
            locationPlace.text = "-"
        } else {
            location.text = "Available"
            locationPlace.text = self.info!["location"].string
        }
    }
    
    func getSkills() {
        let skills = self.info!["cursus_users"][0]["skills"]
        for skill in skills {
            if let skillVal = skill.1["level"].float {
                skillsValuesArray.append(skillVal)
                let result = ("\(skill.1["name"]) - level \(skill.1["level"])")
                skillsTextArray.append(result)
            }
        }
    }
    
    func getProjects() {
        let projects = self.info!["projects_users"]
        for project in projects {
            if project.1["status"] == "finished"{
                projectsArray.append(("\(project.1["project"]["name"])", project.1["final_mark"].int ?? 0, project.1["validated?"].bool ?? false))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.skillTableView {
            return skillsTextArray.count
        } else {
            return projectsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.skillTableView {
            if let cell = skillTableView.dequeueReusableCell(withIdentifier: "Skills") as? SkillsTableViewCell {
                cell.skillNameLevel.text = skillsTextArray[indexPath.row]
                cell.progressSkill.progress = skillsValuesArray[indexPath.row] / 21
                return cell
            }
        } else {
            if let cell = projectTableView.dequeueReusableCell(withIdentifier: "Projects") as? ProjectsTableViewCell {
                cell.projectLabel.text = projectsArray[indexPath.row].0
                if (projectsArray[indexPath.row].2 == true) {
                    cell.finalMarkProject.text = "\(projectsArray[indexPath.row].1)"
                    cell.finalMarkProject.textColor = .green
                } else {
                    cell.finalMarkProject.text = "\(projectsArray[indexPath.row].1)"
                    cell.finalMarkProject.textColor = .red
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}
