//
//  ConnectionManager.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/7/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import Foundation
import Firebase

//let OBSERVATIONS_URL = "https://naturenet-testing.firebaseio.com/observations.json?orderBy=%22$key%22&limitToFirst=4"
//let USERS_URL = "https://naturenet-testing.firebaseio.com/users/"
//let FIREBASE_URL = "https://naturenet-testing.firebaseio.com/"
//let POST_OBSERVATION_URL = "https://naturenet-testing.firebaseio.com/observations/"


// MARK: - *** Connections to Stagging Database ***
//let OBSERVATIONS_URL = "https://naturenet-staging.firebaseio.com/observations.json?orderBy=%22updated_at%22&limitToLast=10"
//let ALL_OBSERVATIONS_URL = "https://naturenet-staging.firebaseio.com/observations/"
//let USERS_URL = "https://naturenet-staging.firebaseio.com/users/"
//let FIREBASE_URL = "https://naturenet-staging.firebaseio.com/"
//let POST_OBSERVATION_URL = "https://naturenet-staging.firebaseio.com/observations/"
//let POST_IDEAS_URL = "https://naturenet-staging.firebaseio.com/ideas/"
//var OBSERVATION_IMAGE_UPLOAD_URL = ""
//let DESIGN_URL = "https://naturenet-staging.firebaseio.com/ideas.json?orderBy=%22updated_at%22&limitToLast=10"
//let COMMENTS_URL = "https://naturenet-staging.firebaseio.com/comments/"
//let SITES_URL = "https://naturenet-staging.firebaseio.com/sites/"


// MARK: - *** Connections to Production Database ***
let OBSERVATIONS_URL = "https://naturenet.firebaseio.com/observations.json?orderBy=%22updated_at%22&limitToLast=4"
let ALL_OBSERVATIONS_URL = "https://naturenet.firebaseio.com/observations/"
let USERS_URL = "https://naturenet.firebaseio.com/users/"
let FIREBASE_URL = "https://naturenet.firebaseio.com/"
let POST_OBSERVATION_URL = "https://naturenet.firebaseio.com/observations/"
let POST_IDEAS_URL = "https://naturenet.firebaseio.com/ideas/"
var OBSERVATION_IMAGE_UPLOAD_URL = ""
let DESIGN_URL = "https://naturenet.firebaseio.com/ideas.json?orderBy=%22updated_at%22&limitToLast=10"
let COMMENTS_URL = "https://naturenet.firebaseio.com/comments/"
let SITES_URL = "https://naturenet-staging.firebaseio.com/sites/"

let MAP_ZOOM_SCALE = 2400.0

class ConnectionManager{
    
    static let sharedManager = ConnectionManager()
        
}
