//
//  InputView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 03/03/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    var title: String
    var placeholder: String
    var issecurefield = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .font(.footnote)
            
            if issecurefield{
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
            }
            else{
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
            }
            Divider()
        }
    }
}

struct InputView_preview: PreviewProvider{
    static var previews: some View{
        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
    }
}
