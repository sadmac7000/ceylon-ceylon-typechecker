import ceylon.file {
    parsePath,
    File
}

import ceylon.ast.redhat {
    compileCompilationUnit
}

import com.vasileff.ceylon.model {
    Package,
    Module
}

"Run the module `com.vasileff.ceylon.typechecker`."
shared void run(){
    value defaultModule = Module(["default"], null);
    value defaultPackage = Package(["default"], defaultModule);

    defaultModule.packages.add(defaultPackage);

    Module resolver([String+] name, String? version) {
        if (name ==  ["ceylon", "language"]) {
            return stubLanguageModule;
        }

        if (name == ["default"], ! exists version) {
            return defaultModule;
        }

        return Module(name, version);
    }

    for (arg in process.arguments) {
        assert (is File f = parsePath(arg).resource);
        value s = StringBuilder();

        try (r = f.Reader()) {
            while(exists l = r.readLine()) {
                s.append(l);
            }
        }

        assert(exists node = compileCompilationUnit(s.string));

        node.visit(TypeChecker(defaultPackage, resolver));
    }
}

