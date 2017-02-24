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
    let description: String // Longest
    let title: String // Shorter than description
    let sectionNumber: String
    let credits: UInt8?
    private(set) var meetings: [CourseMeeting]? // Presumably, an online class has no meetings?
    private(set) lazy var instructors = [Instructor]()
    let levels: [String]?
    
    
    init?(json: JSON) {
        guard let name = json["courseName"].string,
            let description = json["courseDescription"].string,
            let title = json["sectionTitle"].string,
            let sectionNumber = json["courseSectionNumber"].string,
            let credits = json["credits"].uInt8,
            let levels = json["academicLevels"].arrayObject as? [String],
            let instructors = json["instructors"].array
            else {
                log.error("Invalid JSON while initializing Course")
                return nil
        }
        
        self.name = name
        self.description = description
        self.title = title
        self.sectionNumber = sectionNumber
        self.credits = credits
        self.levels = levels
        
        for subJSON in instructors {
            debugPrint(subJSON)
            if let instructor = Instructor(json: subJSON) {
                self.instructors.append(instructor)
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
