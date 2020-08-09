//
//  PreferredWidthTestView.swift
//  SwiftUI-AnchorPrefs
//
//  Created by Jurvis Tan on 2/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct WidthPreference: PreferenceKey {
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = nextValue()
        guard let next = nextValue() else {
            return
        }
        
        if value == nil {
            value = next
            return
        }
        
        let max = [value!, next].max { $0.width < $1.width }
        value = max
    }
    
    static var defaultValue: CGSize? = nil
}

struct PreferredWidthTestView: View {
    
    @State var buttonWidth: CGFloat?
    
    var body: some View {
        HStack {
            BarButton(label: "Btn1", labelWidth: self.buttonWidth)
            BarButton(label: "center", labelWidth: self.buttonWidth)
            BarButton(label: "Button 3", labelWidth: self.buttonWidth)
        }
        .onPreferenceChange(WidthPreference.self) {
            self.buttonWidth = $0?.width
        }
    }
}

struct BarButton: View {
    let label: String
    let labelWidth: CGFloat?
    
    var body: some View {
        Text(label)
            .padding()
            .frame(width: labelWidth)
            .background(Color.blue)
            .overlay(GeometryReader { geometry in
                Color.clear
                    .preference(key: WidthPreference.self, value: geometry.size)
            })
    }
}

struct PreferredWidthTestView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredWidthTestView()
    }
}
