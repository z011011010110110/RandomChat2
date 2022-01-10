//
//  DataControllerTest.swift
//  RandomChat
//
//  Created on 12/25/21.
//

import SwiftUI
import CoreData
import Firebase


class CoreDataViewModel:ObservableObject{
    
    let container: NSPersistentContainer
    @Published var userID = "EgYynnHFreig9FsUGM0t"
    @Published var savedEntities: [User] = []
    @Published var lastMessageID: UUID?
    @Published var chats =
    [Chat(person:Person(name:"", imgString:""),
        messages:[],
        hasReadMessage: false)]
    
    init(){
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { (description, error) in
            if let error = error{
                print("\(error)")
            }
        }
        //fetchData()
        getData()
    }
    
    func fetchData(){
        let request = NSFetchRequest<User>(entityName: "User")
        do{
            savedEntities = try container.viewContext.fetch(request)
        } catch _{
                print("error")
            }
    }
    
    func addUser(text: String){
        let newUser = User(context: container.viewContext)
        newUser.name = text
        saveData()
    }
    
    func deleteUser(indexSet: IndexSet){
        guard let index = indexSet.first else{
            return
        }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    func updateUser(entity: User, edit: String){
        entity.name = edit
        saveData()
        
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchData()
        } catch _{
            print("error")
        }
    }
    
    //Fetches chat data from database
    func getData(){
        let db = Firestore.firestore()
        
        ///get person name
        var person = Person(name:"" , imgString:"")
        db.collection("Users").addSnapshotListener {(snapshot, error) in
            for document in snapshot!.documents {
                let data = document.data()
                let username = data["username"] as? String ?? ""
                let imgString = data["imgString"] as? String ?? ""
                person = Person(name:username , imgString:imgString)
                self.chats[0].person = person
            }
        }
            
        ///Update Messages
        db.collection("Messages").document("hhMpZuYMeBu6RlyNK9wM").collection("message")
            .order(by: "timestamp")
            .addSnapshotListener { [self] (snapshot, error) in
            guard let documents = snapshot?.documents else{
                return
            }
                
            //documents.order(by: "timestamp")
                
            ///Returns Chat every time "Messages" is updated
            self.chats = documents.compactMap { (snapshot) -> Chat in

                var newChat = Chat(person: person, messages:[], hasReadMessage: false)
                
            ///Get all message documents
                for document in documents {
                    let msgData = document.data()
                    let text = msgData["text"] as? String ?? ""
                    let date = msgData["timestamp"] as? Date ?? Date()
                    let senderID = msgData["userID"] as? String ?? ""
                    let msg = (Message(text,type: (senderID == userID) ? .Sent:.Recieved, date:date, senderID: senderID))
                    lastMessageID = msg.id
                    newChat.messages.append(msg)
                    
                }
                return newChat
            }
        }
    }
    
    ///Sends data to database
    func sendData(text: String){
        let db = Firestore.firestore()
        db.collection("Messages").document("hhMpZuYMeBu6RlyNK9wM").collection("message").addDocument(data: [
            "text": text,
            "timestamp": Timestamp(date: Date()),
            "userID": userID
        ])
    }
}



struct DataControllerTest: View {
    
    @StateObject var viewModel = CoreDataViewModel()
    
    @State var textbox: String = ""
    var body: some View {

        NavigationView{
            VStack{


                TextField("New User", text: $textbox)
                
                Button("Submit", action:{
                    viewModel.addUser(text: textbox)
                    //textbox = ""
                }).disabled(textbox.isEmpty)
                    .onAppear{
                        viewModel.fetchData()
                    }
                
                
                List{
                    ForEach(viewModel.savedEntities){user in
                        Text(user.name ?? "")
                            .onTapGesture {
                                viewModel.updateUser(entity: user, edit: textbox)
                            }
                    }
                    .onDelete(perform: viewModel.deleteUser)
                }
                Spacer()
                
            }

        }
    }
}

struct DataControllerTest_Previews: PreviewProvider {
    static var previews: some View {
        DataControllerTest()
    }
}

