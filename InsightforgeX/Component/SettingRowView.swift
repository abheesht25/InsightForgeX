//
//  SettingRowView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 05/03/24.
//

import SwiftUI

struct SettingRowView: View {
    let imagename: String
    let title: String
    let tincolor: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imagename)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tincolor)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

struct SettingRowPreview_Preview: PreviewProvider{
    static var previews: some View{
        SettingRowView(imagename: "gear", title: "Version", tincolor: Color(.systemGray))
    }
}
