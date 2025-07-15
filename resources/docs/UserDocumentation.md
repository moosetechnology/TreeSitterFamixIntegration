# User documentation of Tree Sitter Famix Integration

This project aim to ease the development of Famix importers based on Tree Sitter.

In the different sections of this project we will present the different utilities you can use to build a Famix importer on top of Tree Sitter.

<!-- TOC -->

- [User documentation of Tree Sitter Famix Integration](#user-documentation-of-tree-sitter-famix-integration)
  - [FamixTSNodeWrapper and FamixTSRootNodeWrapper](#famixtsnodewrapper-and-famixtsrootnodewrapper)
    - [Nodes description](#nodes-description)
    - [Does not understand management](#does-not-understand-management)
  - [Inspector extensions](#inspector-extensions)
  - [FamixTSAbstractImporter](#famixtsabstractimporter)
  - [FamixTSAbstractVisitor](#famixtsabstractvisitor)
    - [Specialization of the visit](#specialization-of-the-visit)
    - [Visit of single/multiple fields](#visit-of-singlemultiple-fields)
  - [Comment importer?](#comment-importer)
  - [Error repport](#error-repport)
  - [Symbol resolution](#symbol-resolution)
  - [Context Stack building](#context-stack-building)
  - [Example of parsers written with those tools](#example-of-parsers-written-with-those-tools)

<!-- /TOC -->

## FamixTSNodeWrapper and FamixTSRootNodeWrapper

### Nodes description 

The current implementation of Pharo-Tree-Sitter is using FFI to get all info from the tree. Each time you ask child nodes or parent nodes, you get a new instance. So if you have a TSNode and do: `aTSNode collectNamedChild anyOne parent`, instead of this returnin the same entity than the receiver, you will get a new instance. 

This can make it more complexe to implement some logic, expecially everything linked to the source code management since TreeSitter nodes do not know their source.

This might be improved in the future by improving the FFI binding of TreeSitter, but in the meantime, we are proposing a wrapper for `TSNodes`.

The root node of the tree can be wrapped in a `FamixTSRootNodeWrapper`. This wrapper can have two parameters set:
- `completeSource` : This is the source of the file that produced this parsed tree
- `relativePath` : This is the relative path of the file been parsed from the root `FileReference` provided by the parse

If you use the `FamixTSAbstractVisitor` and the `FamixTSAbstractImporter`, those two will be set automatically without you having to do anything (This happens in `FamixTSRootNode>>#accept:`).

Knowing the complete source allows to enrich the API of the nodes with methods such as:
- `sourceText` : the source of the current node
- `startPosition` : the start position of the node in the file
- `endPosition` : the end position of the node in the file

They will be especially helpful to produce the file references of model to produce. But we will explore this in a future section about the `FamixTSAbstractVisitor`.

`FamixTSRootNodeWrapper` will produce instances of `FamixTSNodeWrapper` once we ask its children. Both those classes reimplement the methods to get the parents or children nodes in order to save the instances and not recreate new instances each time we request them. This allows to access the sources without losing this info.

### Does not understand management

The nodes are wrapping a `TSNode`. Some of the API is reimplemented, but in case it is not the case, then `#doesNotUnderstand:` will forward the message to the wrapped node.

Another utility got added to the `#doesNotUnderstand:`: the easy access to nodes fields.
In the API of `TSNode`, the nodes can have `fields` that are an association between a name and associated nodes (or even a single node).

The API to access such a field is `#nodeChildByFieldName:`. But you also need to check if the field exists. Or you can use `#collectFieldNameOfNamedChild`. For example:

```st
    aTSNode collectFieldNameOfNamedChild at: #name ifPresent: [ :node | famixEntity name: node sourceText ].

    "If it cannot be nil:"
    famixEntity name: (aTSNode nodeChildByFieldName: 'name')
```

 Since this is something we are often doing in the creation of a parser, with a wrapped node it is possible to acces a field using the name of the field prefixed by `_`. If the field does not exist, it returns nil. The previous code becomes:

 ```st
    aTSNode _name ifNotNil: [ :node | famixEntity name: node sourceText ].

    "If it cannot be nil:"
    famixEntity name: aTSNode _name sourceText
 ```

> This might evolve in the future. Currently this is always going through the `#doesNotUnderstand:`, but in the future it is possible that the code will be generated to avoid the warnings from Pharo. Nothing is sure yet.

## Inspector extensions

Another useful feature of this project is to add multiple inspector tabs.

The wrapped node have multiple.

An inspector to see the expanded tree of a node:

![Inspector tree tab](tree.png)

An inspector to see the fields of a node:

![Inspector fields tab](fields.png)

An inspector to see the source code of a node:

![Inspector source tab](source.png)

An inspector to see the source code of a node inside the complete source of the file that produced the node:

![Inspector complete source tab](completeSource.png)

Future inspectors might come. For example I would like an inspector tab to be able to see all the possible symbols of a project, and if possible, the possible parent/children symbols. (But days are only 24h long :'( )

## FamixTSAbstractImporter

TODO
 
## FamixTSAbstractVisitor

TODO

### Specialization of the visit

TODO

### Visit of single/multiple fields

TODO

## Comment importer?

TODO

## Error repport

In the development of a parser it is common to have edge cases that are hard to handle and to have crashes. This project provides a little utility to help handling such cases. This utility comes from the `SymbolResolver` project that we will explore more in the section [Symbol resolution](#symbol-resolution). If everything is fine, you should not have to mange this error report yourself because `TreeSitterFamixIntegration` is managing it for you directly. But here is a little explanation of what happens under the hood.

`SRParsingReport` is instanciated by the `SRSymbolsSolver` in the `errorReport` instance variable during its initialization. It can be used to add a safeguard during the execution of some code to catch errors or warnings without interruptiong the parsing. The `FamixTSAbstractVisitor` instantiate directly this solver and propose the error repport itself.

It can be used during the visit of an AST with a visitor using `SRTSolverUserVisitor` like this:

```st
acceptNode: aNode

	^ self errorReport catch: Error during: [ super acceptNode: aNode ]
```

Or in the case of this project:

```st
FamixTSAbstractVisitor>>#visitNode: aTSNode

	^ self errorReport catch: Exception during: [
			  | visitMethod |
			  visitMethod := (String streamContents: [ :aStream |
					                  aStream nextPutAll: 'visit'.
					                  ($_ split: aTSNode type) do: [ :word | aStream nextPutAll: word capitalized ].
					                  aStream nextPut: $: ]) asSymbol.

			  (self respondsTo: visitMethod)
				  ifTrue: [ self perform: visitMethod with: aTSNode ]
				  ifFalse: [
						  (visitMethod , ' does not exist, visiting only its children') traceCr.
						  super visitNode: aTSNode ] ]

```

This error report is also used during the symbol resolution directly in the method `SRSymbolsSolver>>#resolveUnresolvedSymbols`.

By default, at the end of the parsing, if error happened, they will be inspected. But it is possible to change the behavior by overriding the method `FamixTSAbstractImporter>>#manageErrorReport` in your own importer.

> [!TIP]
> While developping a parser it might be interesting to have an actual debugger instead of catching all the errors. It is possible to go in development mode via the world menu: `Debug > Toggle Symbol Resolver Debug mode`


## Symbol resolution

This project also comes with helps for symbol resolution and the creation of the context stack.

[But a documentation already exist.](https://github.com/jecisc/SymbolResolver/blob/main/resources/docs/UserDocumentation.md)

## Context Stack building

We we are writting an importer, we need to build a stack of contexts. This can be simplified with this project.

[Same as the previous section, the documentation can be found in SymbolResolver documentation.](https://github.com/jecisc/SymbolResolver/blob/main/resources/docs/UserDocumentation.md)

## Example of parsers written with those tools

Here are some parsers written with those tools:
- [https://github.com/moosetechnology/MoosePy](https://github.com/moosetechnology/MoosePy)
- [https://github.com/moosetechnology/Famix-C-Importer](https://github.com/moosetechnology/Famix-C-Importer)