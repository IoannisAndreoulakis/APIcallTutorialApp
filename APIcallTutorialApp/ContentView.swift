//
//  ContentView.swift
//  APIcallTutorialApp
//
//  Created by Ioannis Andreoulakis on 12/2/24.
//
// NOTES //
//
// *1* So after i created a UserView SwiftUIView file with how i want the UI to look like for a User
// then inside here the ContentView i simply add the UserView() list
//
// *2* Now i need to create a link between my View and my ViewModel
// I create a new StateObject instance within my UsersViewModel()
// I use a StateObject to actually listen to my users and pass that user into this View
//
// *3* I need to use a ForEach loop to loop through all the users that i got back from the API response
// The ForEach is going to be based on the 'vm.users'
// *4* Then i add the id to tell it to use the id as a unique identifier for each user within the collection
//
// *5 Now i want to inject my User within this UserView() line 32, so go to the UserView struct
//
// *6* Wrap the list in a ZStack
// Then when appears onto the screen i want you to execute the function to fetch Users
//
// *7* So this will call my function from my ViewModel and start off the process of fetching
// users and show them on my screen
//
// *8* Continued from UserViewModel, im going to add an alert here.
// So on my List, i use the .alert modifier, to check if it should be presented
// based on my 'hasError' boolean, so this property within my ViewModel is set to true
// that will actually show an error on the screen and will also use the error message
// from the error description that i described to show that within the alert as well.
// I also added a button to simply retry it
//
// *9* Coming back from the ViewModel i added this, so what that does?
// Well, if the ViewModel isRefresing then i want to show ProgressView()
// or else to show this List with the Users and if something goes wrong
// it will show an alert in the UI
//
// Now because there is the scenario where the view isRefreshing while i get an error and
// in that case the alert wont show. So for that reason i will attatch the alert on the ZStack
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = UsersViewModel()          // *1 *2
    
    var body: some View {
        NavigationStack {
            ZStack {                                        // *6
                
                if vm.isRefreshing {                        // *9
                    ProgressView()
                } else {
                    
                    List {
                        ForEach(vm.users, id: \.id) { user in   // *3 *4
                            UserView(user: user)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Users")
                    
                }
            }
            .onAppear(perform: vm.fetchUsers)               // *7
            .alert(isPresented: $vm.hasError,           // *8
                   error: vm.error) {
                Button(action: vm.fetchUsers) {
                    Text("Retry")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

