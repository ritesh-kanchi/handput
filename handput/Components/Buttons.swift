//
//  Buttons.swift
//  handput
//
//  Created by Ritesh Kanchi on 10/22/22.
//

import SwiftUI

struct DefaultButton: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.tint)
            .foregroundColor(.white)
            .fontWeight(.medium)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        DefaultButton(text: "Get started")
    }
}
