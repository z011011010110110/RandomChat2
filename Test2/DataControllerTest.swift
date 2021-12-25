//
//  DataControllerTest.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/25/21.
//

import SwiftUI
import CoreData


class CoreDataViewModel:ObservableObject{
    
    let container: NSPersistentContainer
    @Published var savedEntities: [User] = []
    
    init(){
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { (description, error) in
            if let error = error{
                print("\(error)")
            }
        }
        fetchData()
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
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchData()
        } catch _{
            print("error")
        }
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
                    ForEach(viewModel.savedEntities){userx in
                        Text(userx.name ?? "")
                        
//                        Text("1 "+(viewModel.savedEntities[0].name ?? ""))
//                        Text("2 "+(viewModel.savedEntities[1].name ?? ""))
//                        Text("3 "+(viewModel.savedEntities[2].name ?? ""))
//                        Text("4 "+(viewModel.savedEntities[3].name ?? ""))
//                        Text(String(viewModel.savedEntities.count))
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

