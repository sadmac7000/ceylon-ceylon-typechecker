import com.vasileff.ceylon.model {
    ParameterList,
    TypeParameter,
    covariant,
    Module,
    Package,
    ClassDefinition,
    NothingDeclaration,
    InterfaceDefinition,
    Value,
    Parameter,
    contravariant
}

import com.vasileff.ceylon.model.parser {
    parseTypeLG
}

Module loadLanguageModule() {

    value ceylonLanguageModule
        =   Module(["ceylon", "language"], "0.0.0");

    value ceylonLanguagePackage
        =   Package(["ceylon", "language"], ceylonLanguageModule);

    ceylonLanguageModule.packages.add(ceylonLanguagePackage);

    // ceylon.language::Nothing
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        NothingDeclaration(ceylonLanguagePackage.defaultUnit);
    };

    // ceylon.language::Anything
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            unit = ceylonLanguagePackage.defaultUnit;
            name = "Anything";
            extendedTypeLG = null;
            caseTypesLG = [
                parseTypeLG("Object"),
                parseTypeLG("Null")
            ];
        };
    };

    // ceylon.language::Object
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Object";
            extendedTypeLG = parseTypeLG("Anything");
            isAbstract = true;
        };
    };

    // ceylon.language::Identifiable
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        InterfaceDefinition {
            container = ceylonLanguagePackage;
            name = "Identifiable";
        };
    };

    // ceylon.language::Basic satisfies Identifiable
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Basic";
            extendedTypeLG = parseTypeLG("Object");
            satisfiedTypesLG = [parseTypeLG("Identifiable")];
            isAbstract = true;
        };
    };

    // ceylon.language::Null
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Null";
            extendedTypeLG = parseTypeLG("Anything");
        };
    };

    // ceylon.language::Character
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Character";
            extendedTypeLG = parseTypeLG("Object");
        };
    };

    // ceylon.language::String(List<Character>)
    value stringDefinition = ClassDefinition {
        container = ceylonLanguagePackage;
        name = "String";
        extendedTypeLG = parseTypeLG("Object");
    };

    ceylonLanguagePackage.defaultUnit.addDeclaration(stringDefinition);

    value stringArg = Value {
        container = stringDefinition;
        name = "characters";
        typeLG = parseTypeLG("{Character*}");
    };

    stringDefinition.addMembers { stringArg };

    stringDefinition.parameterList
        =   ParameterList([Parameter(stringArg)]);

    // ceylon.language::Entry
    value entryDeclaration
        =   ClassDefinition {
                container = ceylonLanguagePackage;
                name = "Entry";
                extendedTypeLG = parseTypeLG("Object");
                //parameterLists = [ParameterList.empty]; // TODO key, item
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(entryDeclaration);

    entryDeclaration.addMembers {
        TypeParameter {
            container = entryDeclaration;
            name = "Key";
            satisfiedTypesLG = [parseTypeLG("Object")];
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = entryDeclaration;
            name = "Item";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Iterable
    value iterableDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Iterable";
                // TODO satisfies Category
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(iterableDeclaration);

    iterableDeclaration.addMembers {
       TypeParameter {
            container = iterableDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
            defaultTypeArgumentLG = parseTypeLG("Anything");
        },
        TypeParameter {
            container = iterableDeclaration;
            name = "Absent";
            variance = covariant;
            selfTypeDeclaration = null;
            satisfiedTypesLG = [parseTypeLG("Null")];
            defaultTypeArgumentLG = parseTypeLG("Null");
        }
    };

    // ceylon.language::Sequential
    value sequentialDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Sequential";
                satisfiedTypesLG = [
                    parseTypeLG("{Element*}")
                ];
                // TODO satisfies List & Ranged, not iterable
                // TODO cases Empty & Sequence
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(sequentialDeclaration);

    sequentialDeclaration.addMembers {
       TypeParameter {
            container = sequentialDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Sequence
    value sequenceDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Sequence";
                // TODO case types
                satisfiedTypesLG = [
                    parseTypeLG("[Element*]"),
                    parseTypeLG("{Element+}")
                ];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(sequenceDeclaration);

    sequenceDeclaration.addMembers {
       TypeParameter {
            container = sequenceDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Empty
    value emptyDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Empty";
                // TODO case types
                satisfiedTypesLG = [parseTypeLG("[Nothing*]")];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(emptyDeclaration);

    // ceylon.language::Tuple
    value tupleDeclaration
        =   ClassDefinition {
                container = ceylonLanguagePackage;
                name = "Tuple";
                extendedTypeLG = parseTypeLG("Object");
                satisfiedTypesLG = [parseTypeLG("[Element*]")];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(tupleDeclaration);

    tupleDeclaration.addMembers {
        TypeParameter {
            container = tupleDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = tupleDeclaration;
            name = "First";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = tupleDeclaration;
            name = "Rest";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Callable
    value callableDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Callable";
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(callableDeclaration);

    callableDeclaration.addMembers {
        TypeParameter {
            container = callableDeclaration;
            name = "Return";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = callableDeclaration;
            name = "Arguments";
            variance = contravariant;
            selfTypeDeclaration = null;
        }
    };

    return ceylonLanguageModule;
}

Module stubLanguageModule = loadLanguageModule();
