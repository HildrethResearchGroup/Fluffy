//
//  ImageCollectionIconsView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

struct ImageCollectionIconsView: View {
	var filesToShow: [File]
	var lazyDiskImageGroup: String
	var scale: CGFloat = 64.0
	
	var body: some View {
		let columns = [
			GridItem(.adaptive(minimum: scale, maximum: scale * 2), spacing: 10.0)
		]
		ScrollView(.vertical) {
			LazyVGrid(columns: columns) {
				ForEach(filesToShow) { file in
					VStack {
						if let url = file.url {
							LazyDiskImage(at: url,
														in: lazyDiskImageGroup,
														imageSize: CGSize(width: scale * 2, height: scale * 2))
								.scaledToFit()
						} else {
							Text("X")
						}
						Text(file.displayName)
							.lineLimit(1)
					}
					.onDrag {
						let uri = file.objectID.uriRepresentation() as NSURL
						return NSItemProvider(object: uri)
					}
				}
			}
			.padding(10.0)
		}
	}
}

struct ImageCollectionIconsView_Previews: PreviewProvider {
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
		ImageCollectionIconsView(filesToShow: filesToShow,
														lazyDiskImageGroup: "Preview")
	}
}
