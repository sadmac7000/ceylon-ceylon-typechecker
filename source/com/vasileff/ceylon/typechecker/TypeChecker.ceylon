import ceylon.ast.core {
    ...
}

import ceylon.language.meta {
    type
}

import com.vasileff.ceylon.model {
    Unit,
    Package,
    Module,
    Element,
    Scope,

    DeclarationModel=Declaration,
    FunctionModel=Function,
    ModuleImportModel=ModuleImport
}

import ceylon.collection {
    ArrayList,
    HashMap
}

Key<DeclarationModel> declarationKey
    = ScopedKey<DeclarationModel>(`module`, "declaration");

[String+] fullPackageNameToStrings(FullPackageName name)
    => name.components.collect((x) => x.name);

[String+] splitQualifiedName(String name) {
    assert(is [String+] n = name.split('.'.equals).sequence());
    return n;
}

class UnsupportedNode(Node n) extends Exception(type(n).string) {}

class TypeChecker(pkg, resolveModule)
        satisfies Visitor {
    "Package we are compiling for."
    Package pkg;

    "Compilation unit we are type-checking."
    Unit unit = pkg.defaultUnit;

    "Module we are compiling for."
    Module mod => pkg.mod;

    "Function to resolve modules."
    Module([String+],String?) resolveModule;

    class Frame(scope) {
        shared Scope scope;
        shared HashMap<String,FunctionModel> forwardDeclarations
            = HashMap<String,FunctionModel>();

        shared void addMember(DeclarationModel member) {
            if (is Element scope) {
                scope.addMember(member);
            } else {
                /* scope is a package */
                unit.declarations.add(member);
            }
        }
    }

    "Stack of scopes we are processing."
    value stack = ArrayList<Frame>{Frame(unit.pkg)};

    /*"Basic block we are processing."
    shared variable BasicBlock? block;*/

    value frame {
        assert(exists ret = stack.last);
        return ret;
    }

    void push(Frame f) {
        stack.add(f);
    }

    void pop() {
        stack.deleteLast();
    }

    void error(Node node, String message) {
        /* TODO: Something worthwhile with this. */
        print(message);
    }

    //"Nodes to handle by just visiting all children."
    alias StandardNode => ModuleBody;

    //"Nodes to ignore completely."
    //alias IgnoredNode => ModuleCompilationUnit;

    shared actual void visitNode(Node that) {
        /*if (is IgnoredNode that) {
            return;
        }*/

        if (is StandardNode that) {
            that.visitChildren(this);
        }

        throw UnsupportedNode(that);
    }

    shared actual void visitAnyCompilationUnit(AnyCompilationUnit that) {
        for (imp in that.imports) {
            that.visit(this);
        }

        that.moduleDescriptor?.visit(this);
        that.packageDescriptor?.visit(this);

        for (dec in that.declarations) {
            dec.visit(this);
        }
    }

    shared actual void visitPackageDescriptor(PackageDescriptor that) {
        value name = fullPackageNameToStrings(that.name);

        if (pkg.name != name) {
            error(that.name, "Incorrect package name.");
        }

        /* TODO: Annotations */
    }

    shared actual void visitModuleDescriptor(ModuleDescriptor that) {
        value name = fullPackageNameToStrings(that.name);

        if (mod.name != name) {
            error(that.name, "Incorrect module name.");
        }

        if (exists m = mod.version, m != that.version.text) {
            error(that.version, "Incorrect module version.");
        }

        that.body.visit(this);

        /* TODO: Annotations */
    }

    shared actual void visitModuleImport(ModuleImport that) {
        value name =
            switch (t = that.name)
            case (is FullPackageName) fullPackageNameToStrings(t)
            case (is StringLiteral) splitQualifiedName(t.text);

        value version = that.version.text;

        /* TODO: Annotations */

        value imp = ModuleImportModel(resolveModule(name, version), false);

        mod.moduleImports.add(imp);
    }

    shared actual void visitAnyFunction(AnyFunction that) {
        FunctionModel declaration;

        /*if (exists d = ) {
            declaration = d;
        } else {*/
            declaration = FunctionModel{
                container = frame.scope;
                name = that.name.name;
                typeLG = lookupType(that);
            };
        //}

        that.put(declarationKey, declaration);

        if (exists body = that.definition) {
            push(Frame(declaration));
            body.visit(this);
            pop();
        } else {
            frame.forwardDeclarations.put(declaration.name, declaration);
        }
    }
}
