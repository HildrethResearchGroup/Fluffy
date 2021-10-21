//
//  ShowInFinderButton.swift
//  Fluffy
//
//  Created by Beta on 10/21/21.
//

import SwiftUI

struct ShowInFinderButton: View {
    
    var url: URL?
    
    init(_ URLIn: URL?) {
        url = URLIn
    }
    
    var body: some View {
        if let unwrappedURL = url {
            Button {
                unwrappedURL.showInFinder()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct ShowInFinderButton_Previews: PreviewProvider {
    static let url = URL(string: "")
    static var previews: some View {
        ShowInFinderButton(url!)
    }
}
