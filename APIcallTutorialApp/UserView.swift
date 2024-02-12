//
//  UserView.swift
//  APIcallTutorialApp
//
//  Created by Ioannis Andreoulakis on 12/2/24.
//

import SwiftUI

struct UserView: View {
    
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("**Name**: \(user.name)")
            Text("**Email**: \(user.email)")
            Divider()
            Text("**Company**: \(user.company.name)")
            
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10,
                                                                  style: .continuous))
        .padding(.horizontal, 4)
    }
}

#Preview {
    UserView(user: .init(id: 0,
                         name: "Tunds",
                         email: "Tunds@gmail.com",
                         company: .init(name:"Tundsdev")))
}
