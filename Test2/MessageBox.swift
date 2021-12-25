//
//  MessageBox.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/23/21.
//

import SwiftUI

struct MessageBox: View {
    
    var text: String
    var user = false
    
    var body: some View {
        if(user)
        {
            HStack{
                Spacer()
                Text(text)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(15)
            }
        }
        if(!user)
        {
            HStack{
                Text(text)
                    .foregroundColor(Color.black)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(15)
                    Spacer()
            }
        }
    }
}
