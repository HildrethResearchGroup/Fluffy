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
	@Binding var thumbnailScale: CGFloat
	
	var body: some View {
		let columns = [
			GridItem(.adaptive(minimum: thumbnailScale, maximum: thumbnailScale * 2), spacing: 10.0)
		]
		ScrollView(.vertical) {
			LazyVGrid(columns: columns) {
				ForEach(filesToShow) { file in
					VStack {
						if let url = file.url {
							LazyDiskImage(at: url,
														in: lazyDiskImageGroup,
														imageSize: CGSize(width: thumbnailScale * 2, height: thumbnailScale * 2))
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
	@State static var thumbnailScale: CGFloat = 64.0
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
														 lazyDiskImageGroup: "Preview",
														 thumbnailScale: $thumbnailScale)
	}
}
