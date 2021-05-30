//
//  DetailView.swift
//  Images
//
//  Created by Connor Barnes on 5/30/21.
//

import SwiftUI

struct DetailView: View {
	var file: File
	
	var body: some View {
		if let url = file.url,
			 let image = NSImage(contentsOf: url) {
			Image(nsImage: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
			Text("Failed to load image")
		}
	}
}

// MARK:- Preview
struct DetailView_Previews: PreviewProvider {
	static let file: File = {
		let fetchRequest: NSFetchRequest<File> = File.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return fetchResult.first!
	}()
	
	static var previews: some View {
		DetailView(file: file)
	}
}
