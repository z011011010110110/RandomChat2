//
//  MessageModel.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/24/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Chat: Identifiable{
    var id: UUID {person.id}
    var person: Person
    var messages: [Message]
    var hasReadMessage = false
}

struct Person: Identifiable{
    let id = UUID()
    let name: String
    let imgString: String
    var geopoint: Geopoint
}

struct Geopoint:Identifiable{
    let id = UUID()
    
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

struct Message: Identifiable{
    enum MessageType{
        case Sent, Recieved
    }
    
    
    let id = UUID()
    let senderID: String
    let date: Date
    let text: String
    let type: MessageType
    
    init(_ text:String, type:MessageType, date:Date, senderID:String){
        self.date = date
        self.type = type
        self.text = text
        self.senderID = senderID
    }
    
    init(_ text:String, type:MessageType, senderID:String){
        self.init(text, type:type, date:Date(), senderID:senderID)
    }
}



