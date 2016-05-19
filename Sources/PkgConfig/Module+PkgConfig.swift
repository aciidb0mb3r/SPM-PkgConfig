/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// Filters the flags with allowed arguments so unexpected arguments are not passed to
/// compiler/linker. List of allowed flags:
/// cFlags: -I, -L
/// libs: -L, -l, -F, -framework
func whitelist(pcFile: String, flags: (cFlags: [String], libs: [String])) throws {
    // Returns an array of flags which doesn't match any filter.
    func filter(flags: [String], filters: [String]) -> [String] {
        var filtered = [String]()     
        var it = flags.makeIterator()
        while let flag = it.next() {
            guard let filter = filters.filter({ flag.hasPrefix($0) }).first else {
                filtered += [flag]
                continue
            }
            // If the flag and its value are separated, skip next flag.
            if flag == filter {
                guard let _ = it.next() else {
                   fatalError("Expected associated value") 
                }
            }
        }
        return filtered
    }
    let filtered = filter(flags: flags.cFlags, filters: ["-I", "-L"]) + filter(flags: flags.libs, filters: ["-L", "-l", "-F", "-framework"])
    guard filtered.isEmpty else {
        throw PkgConfigError.NonWhitelistedFlags("Non whitelisted flags found: \(filtered) in pc file \(pcFile)")
    }
}
