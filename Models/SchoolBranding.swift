import Foundation
import SwiftUI

enum School: String, CaseIterable {
    case kennesawState = "kennesaw.edu"
    case georgiaState = "gsu.edu"
    case uga = "uga.edu"
    case defaultSchool = "default"
    
    var name: String {
        switch self {
        case .kennesawState: return "Kennesaw State University"
        case .georgiaState: return "Georgia State University"
        case .uga: return "University of Georgia"
        case .defaultSchool: return "Your School"
        }
    }
    
    var mascot: String {
        switch self {
        case .kennesawState: return "Owl"
        case .georgiaState: return "Panther"
        case .uga: return "Bulldog"
        case .defaultSchool: return "Graduation Cap"
        }
    }
    
    // Official Kennesaw State colors: #FFD700 (Gold) and #000000 (Black)
    // Official Georgia State colors: #003A70 (Blue) and #E31C23 (Red)
    // Official UGA colors: #BA0C2F (Red) and #000000 (Black)
    
    var primaryColor: Color {
        switch self {
        case .kennesawState: return Color(red: 1.0, green: 0.843, blue: 0.0) // #FFD700 - Official KSU Gold
        case .georgiaState: return Color(red: 0.0, green: 0.227, blue: 0.439) // #003A70 - Official GSU Blue
        case .uga: return Color(red: 0.729, green: 0.047, blue: 0.184) // #BA0C2F - Official UGA Red
        case .defaultSchool: return .blue
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .kennesawState: return Color(red: 0.0, green: 0.0, blue: 0.0) // #000000 - Black
        case .georgiaState: return Color(red: 0.890, green: 0.110, blue: 0.137) // #E31C23 - Red accent
        case .uga: return Color(red: 0.0, green: 0.0, blue: 0.0) // #000000 - Black
        case .defaultSchool: return .gray
        }
    }
    
    var logoImageName: String {
        switch self {
        case .kennesawState: return "ksu_logo" // You'll add this asset to Xcode
        case .georgiaState: return "gsu_logo" // You'll add this asset to Xcode
        case .uga: return "uga_logo" // You'll add this asset to Xcode
        case .defaultSchool: return ""
        }
    }
    
    var logoIcon: String {
        switch self {
        case .kennesawState: return "bird.fill" // Owl icon for Kennesaw State
        case .georgiaState: return "pawprint.fill" // Panther fallback
        case .uga: return "dog.fill" // Bulldog fallback
        case .defaultSchool: return "building.columns.fill"
        }
    }
    
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SchoolBranding {
    static func detectSchool(from email: String) -> School {
        let emailLower = email.lowercased()
        
        for school in School.allCases where school != .defaultSchool {
            if emailLower.contains(school.rawValue) {
                return school
            }
        }
        
        return .defaultSchool
    }
    
    static func getSchool(from email: String) -> School {
        return detectSchool(from: email)
    }
}

// Comprehensive list of US institutions for dropdown
struct USInstitution: Equatable {
    let name: String
    let domain: String
    let state: String
    
    static let allInstitutions: [USInstitution] = [
        // Georgia (Demo Schools)
        USInstitution(name: "Kennesaw State University", domain: "kennesaw.edu", state: "Georgia"),
        USInstitution(name: "Georgia State University", domain: "gsu.edu", state: "Georgia"),
        USInstitution(name: "University of Georgia", domain: "uga.edu", state: "Georgia"),
        
        // Major Universities
        USInstitution(name: "Harvard University", domain: "harvard.edu", state: "Massachusetts"),
        USInstitution(name: "Stanford University", domain: "stanford.edu", state: "California"),
        USInstitution(name: "Massachusetts Institute of Technology", domain: "mit.edu", state: "Massachusetts"),
        USInstitution(name: "Yale University", domain: "yale.edu", state: "Connecticut"),
        USInstitution(name: "Princeton University", domain: "princeton.edu", state: "New Jersey"),
        USInstitution(name: "Columbia University", domain: "columbia.edu", state: "New York"),
        USInstitution(name: "University of Chicago", domain: "uchicago.edu", state: "Illinois"),
        USInstitution(name: "University of Pennsylvania", domain: "upenn.edu", state: "Pennsylvania"),
        USInstitution(name: "California Institute of Technology", domain: "caltech.edu", state: "California"),
        USInstitution(name: "Duke University", domain: "duke.edu", state: "North Carolina"),
        
        // State Universities
        USInstitution(name: "University of California, Berkeley", domain: "berkeley.edu", state: "California"),
        USInstitution(name: "University of California, Los Angeles", domain: "ucla.edu", state: "California"),
        USInstitution(name: "University of Michigan", domain: "umich.edu", state: "Michigan"),
        USInstitution(name: "University of Virginia", domain: "virginia.edu", state: "Virginia"),
        USInstitution(name: "University of North Carolina", domain: "unc.edu", state: "North Carolina"),
        USInstitution(name: "University of Texas at Austin", domain: "utexas.edu", state: "Texas"),
        USInstitution(name: "University of Florida", domain: "ufl.edu", state: "Florida"),
        USInstitution(name: "Ohio State University", domain: "osu.edu", state: "Ohio"),
        USInstitution(name: "Pennsylvania State University", domain: "psu.edu", state: "Pennsylvania"),
        USInstitution(name: "University of Wisconsin", domain: "wisc.edu", state: "Wisconsin"),
        
        // More Georgia Schools
        USInstitution(name: "Georgia Institute of Technology", domain: "gatech.edu", state: "Georgia"),
        USInstitution(name: "Emory University", domain: "emory.edu", state: "Georgia"),
        USInstitution(name: "Georgia Southern University", domain: "georgiasouthern.edu", state: "Georgia"),
        USInstitution(name: "University of West Georgia", domain: "westga.edu", state: "Georgia"),
        
        // Additional Major Universities
        USInstitution(name: "New York University", domain: "nyu.edu", state: "New York"),
        USInstitution(name: "Northwestern University", domain: "northwestern.edu", state: "Illinois"),
        USInstitution(name: "Cornell University", domain: "cornell.edu", state: "New York"),
        USInstitution(name: "Brown University", domain: "brown.edu", state: "Rhode Island"),
        USInstitution(name: "Dartmouth College", domain: "dartmouth.edu", state: "New Hampshire"),
        USInstitution(name: "Vanderbilt University", domain: "vanderbilt.edu", state: "Tennessee"),
        USInstitution(name: "Rice University", domain: "rice.edu", state: "Texas"),
        USInstitution(name: "Washington University in St. Louis", domain: "wustl.edu", state: "Missouri"),
        USInstitution(name: "University of Notre Dame", domain: "nd.edu", state: "Indiana"),
        USInstitution(name: "Georgetown University", domain: "georgetown.edu", state: "District of Columbia"),
        
        // More State Universities
        USInstitution(name: "Arizona State University", domain: "asu.edu", state: "Arizona"),
        USInstitution(name: "University of Arizona", domain: "arizona.edu", state: "Arizona"),
        USInstitution(name: "University of Colorado", domain: "colorado.edu", state: "Colorado"),
        USInstitution(name: "University of Washington", domain: "washington.edu", state: "Washington"),
        USInstitution(name: "University of Oregon", domain: "uoregon.edu", state: "Oregon"),
        USInstitution(name: "University of Southern California", domain: "usc.edu", state: "California"),
        USInstitution(name: "Boston University", domain: "bu.edu", state: "Massachusetts"),
        USInstitution(name: "Northeastern University", domain: "northeastern.edu", state: "Massachusetts"),
        USInstitution(name: "University of Illinois", domain: "illinois.edu", state: "Illinois"),
        USInstitution(name: "Purdue University", domain: "purdue.edu", state: "Indiana"),
        
        // Additional Schools
        USInstitution(name: "University of Miami", domain: "miami.edu", state: "Florida"),
        USInstitution(name: "Florida State University", domain: "fsu.edu", state: "Florida"),
        USInstitution(name: "University of South Carolina", domain: "sc.edu", state: "South Carolina"),
        USInstitution(name: "Clemson University", domain: "clemson.edu", state: "South Carolina"),
        USInstitution(name: "Auburn University", domain: "auburn.edu", state: "Alabama"),
        USInstitution(name: "University of Alabama", domain: "ua.edu", state: "Alabama"),
        USInstitution(name: "Louisiana State University", domain: "lsu.edu", state: "Louisiana"),
        USInstitution(name: "University of Tennessee", domain: "utk.edu", state: "Tennessee"),
        USInstitution(name: "University of Kentucky", domain: "uky.edu", state: "Kentucky"),
        USInstitution(name: "University of Arkansas", domain: "uark.edu", state: "Arkansas"),
    ]
}

extension UserProfile {
    var school: School {
        SchoolBranding.detectSchool(from: email)
    }
    
    var schoolColors: (primary: Color, secondary: Color) {
        (school.primaryColor, school.secondaryColor)
    }
}

