//
//  Course.swift
//  TUHub
//
//  Created by Connor Crawford on 2/23/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import SwiftyJSON

struct Course {

    let name: String // Course code
    let description: String? // Longest name
    let title: String // Shorter than description
    let sectionNumber: String
    let credits: UInt8?
    private(set) var meetings: [CourseMeeting]? // Presumably, an online class has no meetings?
    private(set) var instructors: [Instructor]? // Not provided in fullview or calendar view
    let levels: [String]?
    
    
    init?(json: JSON) {
        guard let name = json["courseName"].string,
            let title = json["sectionTitle"].string,
            let sectionNumber = json["courseSectionNumber"].string
            else {
                log.error("Invalid JSON while initializing Course")
                return nil
        }
        
        self.name = name
        self.description = json["courseDescription"].string
        self.title = title
        self.sectionNumber = sectionNumber
        self.credits = json["credits"].uInt8
        self.levels = json["academicLevels"].arrayObject as? [String]
        
        if let instructorsJSON = json["instructors"].array {
            for subJSON in instructorsJSON {
                debugPrint(subJSON)
                if let instructor = Instructor(json: subJSON) {
                    if instructors == nil {
                        instructors = [Instructor]()
                    }
                    instructors!.append(instructor)
                }
            }
        }
        
        if let meetingPatterns = json["meetingPatterns"].array {
            for subJSON in meetingPatterns {
                if let meeting = CourseMeeting(json: subJSON) {
                    if meetings == nil {
                        meetings = [CourseMeeting]()
                    }
                    meetings!.append(meeting)
                }
            }
        }
        
    }
    
}
