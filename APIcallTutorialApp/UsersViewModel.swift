//
//  UsersViewModel.swift
//  APIcallTutorialApp
//
//  Created by Ioannis Andreoulakis on 12/2/24.
//
// *1* When i construct the URL its actually possible that it might be invalid
// so i need to safely unwrap the URL, access it and make sure that i'm not trying to use a nil,
// thats why i use 'if let url = ....'
//
// *2* Next i use the URLSession framework to handle executing the network request
// So what is this doing? Its using the .shared instance which is a singleton
// and the i'm passing the url and tell it to actually start the process to excute this URL "https://jsonplaceholder.typicode.com/users"
// so that i get a repsonse back from the servers
//
// *3* So when i get a responce back from the servers i 'll actually get that within
// the closer there { data, response, error in
// DATA: That returns to me the data back from the servers (all the data in the JSON essentially)
// RESPONSE: i also get back a response which i need to inspect what i got back on response
// such as the state is called or smth went wrong
// or if something was being sent to a specific endpoint.
// ERROR: And finally we get an error that tells me if when it tried to execute the request something went wrong
//
// *4* Next step is to call a function named .resume() to start the task and executes it for me so
// i can actually handle the response within the closure
//
// *5* In my closure what i have now, is i'm unwrapping the error if there is one,
// so if the error object is not nil then going to handle any errors within this case
//
// *6* Next i create this object called JSONDecoder() that allows me to use the decoder
// to convert the data objet into a object that conforms to Decodable (but since i use Codable
// Codable = Decodable & Encodable).
// So what this will do? It will actually try to convert the data that i got back from the servers
// to the model that i created and maped as Codable if the properties that i defined within match
//
// *7* I safely unwrap the data so if the data is nil isn't going to fail.
// After that i want to use the decoder to try to decode my data to this type [User]
// and thats because in the JSON there is no a single user, there are many, a collection of users essentially.
//
// *8* The source of truth! Essentially its this property that my View will listen to in order for the View to react
// to those changes. So i want to show a list of users on my screen. The reason i have an empty array is cause
// when i load up the app for the first time there wont actually be any users, is only until i execute the NETWORK REQUEST
// will then set this to what my function has tried to decode.
//
// *9* Now i have my users being set. BUT i could have a potential problem here called a retain cycle
// which means that my object which is my View's UsersViewModel will actually be removed when the system
// tries to get rid of it. To avoid this, is actually set out closure to be weak by adding '[weak self]'
// and that means that all of our objects within this class are actually optional now within this closure.
// To fix that, i add a '?' next to self?.users = users
//
// *10 IMPORTANT, i now want to make sure both the network call and the response are happening on the main thread
// to do that i add 'DispatchQueue.main.async {} ' on line 70 and then
// Cut every thing from the if let error till the last else and paste it inside the DispatchQueue body.
//
// *11* Now i need to handle the error. First off i add a UserError
// The reason why i use LocalizedError is cause it allows me to customize the error description, the recovery and suggestion as well
// and i have two cases in this enum
//
// *12* So now within our ViewModel i have a property that tells my View wether an error has occured
// and also have a property here '@Published var error: UserError?' that holds the error if something went wrong
//
// *13* Here i always set the error to false since every time i call this function initially and start to fetch the user
// nothing is actually gone wrong yet so i always want to reset the state of this back to false
//
// *14* Obviously enough i set the error to true here since this is where i handle the scenario of an error
// and also safely unwraping
// also i set the error property within my Published property in this ViewModel to be a custom error with w/e went wrong
// from the URLSession
// *15* The next error i need to handle is if something goes wrong when i try to decode my Users,
// when i try to map the response back to my Model
//
// *16* Now if any of these errors sets to true i want to show an alert on my screen. (go to ContentView)
//
// *17* I will add a loading spinner when the user hits the Retry button that might take some time to load.
// I do this by adding another property in my ViewModel called isRefreshing that allows to listen to the changes as to wether
// fetching data or not.
// The reason i mapped it as 'private(set)' is cause actually i dont want this property specifically to
// be changed outside this ViewModel. I only want the View to be able to read wether is Refreshing or not.
// *18* So when i fetch the Users i actually want to set this to true cause its actually gets Refreshing, also set it
// back to false as the last thing that needs to be done.
//
// *19* Setting it to false and make sure is inside the Dispatch body other wise it will mess with the view refreshing 
//
// Continue to ContentView
//
// *20* Just temporarilly for the sake of the tutorial i added a little timer on the DispatchQueue
// to show the loading spinner, otherwise because of the speed of the app and internet connection it would never show

import Foundation

final class UsersViewModel: ObservableObject {
    
    @Published var users: [User] = []                                           // *8
    @Published var hasError = false
    @Published var error: UserError?
    @Published private(set) var isRefreshing = false                            // *17
    
    func fetchUsers() {
        
        isRefreshing = true                                                     // *18
        hasError = false                                                        // *13
        
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        if let url = URL(string: usersUrlString) {                              // *1
            
            URLSession                                                          // *2
                .shared
                .dataTask(with: url) { [weak self] data, response, error in     // *3*
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {     // *20
                        
                        if let error = error {                                  // *5
                            self?.hasError = true                               // *14
                            self?.error = UserError.custom(error: error)        // *14
                        } else {
                            
                            let decoder = JSONDecoder()                         // *6
                            decoder.keyDecodingStrategy = .convertFromSnakeCase // Handle properties that look like first_name > firstName
                            
                            
                            if let data = data,                                 // *7
                               let users = try? decoder.decode([User].self, from: data) {
                                // TODO: Handle setting the data
                                
                                self?.users = users                             // *9
                                
                            } else {
                                self?.hasError = true                           // *15
                                self?.error = UserError.failedToDecode
                            }
                            
                        }
                        
                        self?.isRefreshing = false                              // *19
                        
                    }
     
                }.resume()                                                       // *4
            
        }
    }
}

extension UsersViewModel {
    enum UserError: LocalizedError {                                             // *11
        case custom(error: Error)
        case failedToDecode
        
        var errorDescription: String? {
            switch self {
            case .failedToDecode:
                return "Failed to decode response"
            case .custom(let error):
                return error.localizedDescription
            }
        }
    }
}
