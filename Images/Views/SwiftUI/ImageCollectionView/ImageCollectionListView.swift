//
//  ImageCollectionListView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

struct ImageCollectionListView: View {
	var filesToShow: [File]
	var lazyDiskImageGroup: String
	
	var body: some View {
		List {
			ForEach(filesToShow) { file in
				HStack {
					if let url = file.url {
						LazyDiskImage(at: url,
													in: lazyDiskImageGroup,
													imageSize: CGSize(width: 24.0, height: 24.0))
							.scaledToFit()
							.frame(width: 24.0, height: 24.0)
					} else {
						Text("X")
					}
					Text(file.displayName)
				}
				.onDrag {
					let uri = file.objectID.uriRepresentation() as NSURL
					return NSItemProvider(object: uri)
				}
			}
		}
	}
}

struct ImageCollectionListView_Previews: PreviewProvider {
	static var filesToShow: [File] {
		let fetchRequest: NSFetchRequest<Directory> = Directory.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return fetchResult
			.flatMap { $0.files.compactMap { $0 as? File } }
	}
	
	static var previews: some View {
		ImageCollectionListView(filesToShow: filesToShow,
														lazyDiskImageGroup: "Preview")
	}
}
