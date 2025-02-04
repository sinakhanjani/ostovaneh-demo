//
//  ButtonView.swift
//  Sample
//
//  Created by Sina khanjani on 12/8/1399 AP.
//

import SwiftUI

public struct CustomButton: View {
    
    var title: String
    var image: Image?
    var buttonTapped: onTappedHandler!

    public var body: some View {
        VStack {
            if image != nil {
                buttonWithImgAndTitle()
            } else {
                buttonWithTitle()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: DEFAULT_RATIO_58, maxHeight: .none, alignment: .center)
    }
    
    private func buttonWithImgAndTitle() -> some View  {
        Button(action: buttonTapped, label: {
            Text(title)
                .font(.iranSans(.bold, size: 17))
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .padding()
                .frame(maxWidth: .infinity)
            Spacer()
            image!
                .padding()
        })
    }

    private func buttonWithTitle() -> some View  {
        Button(action: buttonTapped, label: {
            Text(title)
                .font(.iranSans(.bold, size: 17))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        })
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(title: "Start", buttonTapped: {})
            .background(Color.heavyBlue)
            .previewLayout(.sizeThatFits)
    }
}
