@testable import PkgConfig
import Utility
import POSIX 

func scanDir(dir: String) throws -> Int {
    precondition(dir.isDirectory)
    var count = 0
    print("Scanning folder: \(dir)")
    try walk(dir, recursively: false).forEach { pcFile in
        var parser = PkgConfigParser(pcFile: pcFile)
        try parser.parse()
        count += 1
        do {
            try whitelist(pcFile: pcFile, flags: (parser.cFlags, parser.libs))
        } catch PkgConfigError.NonWhitelistedFlags(let flags) {
            print(flags)
        }
    }
    return count
}

do {
    let searchPaths = try? POSIX.popen(["pkg-config", "--variable", "pc_path", "pkg-config"])
    let paths = searchPaths?.characters.split(separator: ":").map(String.init) ?? []
    var count = 0
    for path in paths where path.isDirectory {
        count += try scanDir(dir: path)
    }
    print("Files scanned: \(count)")
} catch {
    print("Error \(error)")
}
