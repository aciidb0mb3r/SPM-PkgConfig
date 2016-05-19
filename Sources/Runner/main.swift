@testable import PkgConfig
import Utility

var count = 0

func scanDir(dir: String) throws {
    precondition(dir.isDirectory)
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
}

do {
    let paths = ["/usr/local/lib/pkgconfig", "/usr/local/share/pkgconfig",
                "/usr/lib/pkgconfig", "/usr/local/Library/ENV/pkgconfig/10.11"]
    for path in paths where path.isDirectory {
        try scanDir(dir: path)
    }
    print("Files scanned: \(count)")
} catch {
    print("Error \(error)")
}
