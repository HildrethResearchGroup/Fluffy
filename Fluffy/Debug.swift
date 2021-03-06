//
//  Debug.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//

#if DEBUG
/// Setting this value to `true` deletes and resets the Core Data store the next time the app is run in `DEBUG` mode.
let shouldResetCoreData = false

/// Setting this value to `true` will use the preview store instead of the disk store.
let usePreview = false

/// Setting this value to `true` will simulate the root directory failing to load.
let forceThrowForLoadRootDirectory = false

/// A custom error used for simulating errors while debugging.
struct DebugError: Error, CustomStringConvertible {
	var description: String {
		return "Simulated Error"
	}
}
#endif
