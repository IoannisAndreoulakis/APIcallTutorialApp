//
//  UserModel.swift
//  APIcallTutorialApp
//
//  Created by Ioannis Andreoulakis on 12/2/24.
//

import Foundation

// Codable is an object that allows me to convert and map my JSON to my Swift Models or turn Swift Models into JSON

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let company: Company
}

// Inside the JSON the company is a different object within the user object. For this reason i create a new company struct
// and then inside the User struct i add the company variable with Company object as its data type.
struct Company: Codable {
    let name: String
}
