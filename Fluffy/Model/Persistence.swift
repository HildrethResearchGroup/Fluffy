//
//  Persistence.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//

import CoreData

/// A controller responsible for controlling the application's persistence state.
struct PersistenceController {
	/// The Core Data persistent container.
	let container: NSPersistentContainer
	
	/// Creates a new persistence controller.
	/// - Parameter inMemory: If `true`, the store is stored in memory, otherwise, the default disk storage method is used (SQLite).
	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: Self.dataModelName)
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		
		#if DEBUG
		if shouldResetCoreData {
			deleteStore()
		}
		#endif
		
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// TODO: Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
}

// MARK:- Singleton
extension PersistenceController {
	#if DEBUG
	/// The shared persistence controller for the app.
	static let shared = usePreview ? preview : PersistenceController()
	#else
	/// The shared persistence controller for the app.
	static let shared = PersistenceController()
	#endif
}

// MARK:- Constants
extension PersistenceController {
	/// The name of the Core Data model.
	private static let dataModelName = "Fluffy"
	
	/// The store type for Core Data to use (SQLite).
	///
	/// SQLite is used because it is nonatomic, so the whole data-graph doesn't need to be all loaded in memory at all times.
	private static let storeType = "sqlite"
}

// MARK:- Helper functions
extension PersistenceController {
	/// A function that creates a new root directory. This is done if there is no root directory yet.
	private func makeRootDirectory() throws -> Directory {
		let directory = Directory(context: container.viewContext)
		try container.viewContext.save()
		return directory
	}
	
	/// Fetches any directory in the store (if one exists).
	/// - Throws: If the fetch failed.
	/// - Returns: A directory in the store.
	private func fetchAnyDirectory() throws -> Directory? {
		let request = NSFetchRequest<Directory>(entityName: "Directory")
		request.fetchLimit = 1
		
		return try container
			.viewContext
			.fetch(request)
			.first
	}
	
	/// Loads the root directory in the store, creating one if one does not exist.
	/// - Returns: The store's root directory instance.
	func loadRootDirectory() -> Result<Directory, Error> {
		return .init { () -> Directory in
			#if DEBUG
			if forceThrowForLoadRootDirectory {
				throw DebugError()
			}
			#endif
			
			guard var child = try fetchAnyDirectory() else {
				// There were no results returned, so make a root directory
				return try makeRootDirectory()
			}
			// Recursively set the child to the parent in order to traverse up the tree until there is no parent. The root has no parent
			while let parent = child.parent {
				child = parent
			}
			return child
		}
	}
}

// MARK:- Store management
extension PersistenceController {
	/// Deletes the store.
	///
	/// A useful utility for deleting all data for debugging purposes. When the data schema is changed, this should be called, or Core Data will fail to read the data. To have this called while in `DEBUG`, simply set `shouldResetCoreData` to `true` in `Debug.swift`.
	///
	/// - Warning: This will permanently delete all saved data.
	private func deleteStore() {
		// The file is stored at ~/ApplicationSupport/Graphs/GraphsModel.sqlite
		let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("Graphs/\(Self.dataModelName).\(Self.storeType)")
		
		if FileManager.default.fileExists(atPath: url.path) {
			print("[INFO] Core Data store exists. Attempting to delete.")
		} else {
			print("[INFO] Core Data store does not exist.")
			return
		}
		
		do {
			let coordinator = container.persistentStoreCoordinator
			try coordinator.destroyPersistentStore(at: url,
																						 ofType: Self.dataModelName,
																						 options: nil)
			print("[INFO] Core Data store deleted.")
		} catch {
			print("[WARNING] Core Data store not deleted: \(error)")
		}
	}
}

// MARK:- Preview
extension PersistenceController {
	/// A persistence controller used for previewing views.
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		
		let diskRootPath = "/Users/connorbarnes/Desktop/Examples/Images/"
		
		let root = Directory(context: viewContext)
		
		let natureDirectory = Directory(context: viewContext)
		natureDirectory.customName = "Nature"
		natureDirectory.parent = root
		
		let landmarksDirectory = Directory(context: viewContext)
		landmarksDirectory.customName = "Landmarks"
		landmarksDirectory.parent = root
		
		let friendsDirectory = Directory(context: viewContext)
		friendsDirectory.customName = "Friends"
		friendsDirectory.parent = root
		
		let treesDirectory = Directory(context: viewContext)
		treesDirectory.customName = "Trees"
		treesDirectory.parent = natureDirectory
		
		let flowersDirectory = Directory(context: viewContext)
		flowersDirectory.customName = "Flowers"
		flowersDirectory.parent = natureDirectory
		
		let images: [(String, Directory, String?)] = [
			("Beach.jpg", natureDirectory, nil),
			("Mountain.jpg", natureDirectory, nil),
			("Jungle.jpg", natureDirectory, nil),
			("Palm.jpg", treesDirectory, nil),
			("Aspen.jpg", treesDirectory, nil),
			("Tulip.png", flowersDirectory, nil),
			("Sunflower.jpg", flowersDirectory, "Sun Flower"),
			("Eiffel.jpg", landmarksDirectory, "Eiffel Tower"),
			("SanFran.jpg", landmarksDirectory, "Golden Gate Bridge"),
			("Burj.jpg", landmarksDirectory, "Burj Khalifa"),
			("Clayton.jpeg", friendsDirectory, nil),
			("Abdul.jpeg", friendsDirectory, "Abdul Nasser"),
			("Nadi.jpeg", friendsDirectory, "Nadira"),
			("Luke.JPG", friendsDirectory, nil),
		]
		
		images.forEach { fileName, parent, customName in
			let newFile = File(context: viewContext)
			newFile.url = URL(fileURLWithPath: diskRootPath + fileName)
			newFile.customName = customName
			newFile.parent = parent
		}
		
		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()
}
