//
//  Test2App.swift
//  Test2
//
//  Created by Hyunbin Joo on 12/25/21.
//

import SwiftUI
import Firebase
@main
struct Test2App: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            //Geolocation()
            ChatroomView()
            //ContentView()
            //FirebaseData()
        }
    }
}
