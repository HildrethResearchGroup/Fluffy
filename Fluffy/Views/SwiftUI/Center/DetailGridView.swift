//
//  DetailGridView.swift
//  Fluffy
//
//  Created by Beta on 10/10/21.
//

import SwiftUI

/// A view for displaying a collection of images in a row
struct DetailGridView: View {
    /// Manage the selection
    @EnvironmentObject var selectionManager: SelectionManager
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach($selectionManager.fileSelectionArray, id: \.self) { $file in
                    VStack{
                        Text(file.displayName)
                        DetailView(file: file)
                    }
                }
            }
        }
    }// END: Body
}



// MARK: - Previews
struct DetailGridView_Previews: PreviewProvider {
    static var previews: some View {
        DetailGridView()
    }
}
