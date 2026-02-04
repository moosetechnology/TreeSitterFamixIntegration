"
I am the base structure to write a Famix importer based on TreeSitter. Check the documentation on github for more info.
"
Class {
	#name : 'FamixTSAbstractImporter',
	#superclass : 'Object',
	#instVars : [
		'rootReference',
		'visitor'
	],
	#category : 'TreeSitter-Famix-Integration-Core',
	#package : 'TreeSitter-Famix-Integration',
	#tag : 'Core'
}

{ #category : 'accessing' }
FamixTSAbstractImporter class >> import: aFileReference [
	"Launch the import on the file reference provided. 
	It can be a single file to parse or a directory containing a full project."

	^ self new import: aFileReference
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> errorReport [

	^ visitor errorReport
]

{ #category : 'importing' }
FamixTSAbstractImporter >> import: aFileReference [

	rootReference := aFileReference asFileReference. "In case the user provided a file name instead of a file reference."

	self initializeVisitorAndModel.

	"See comment of #shouldCheckForDuplicatedEntitiesInCollections"
	FMShouldCheckForDuplicatedEntitiesInMultivalueLinks value: self shouldCheckForDuplicatedEntitiesInCollections during: [
			self preparsingHook.

			self importFileReference: rootReference.

			visitor resolveUnresolvedSymbols ].

	self manageErrorReport.

	^ self model
]

{ #category : 'importing' }
FamixTSAbstractImporter >> importFile: aFileReference [

	| parser tree |
	('Importing ' , aFileReference pathString) traceCr.

	parser := TSParser new.
	parser language: self treeSitterLanguage.

	visitor fileReference: aFileReference.
	tree := parser parseString: visitor fileReference binaryReadStream upToEnd usingTree:  ExternalAddress null  encoding: visitor treeSitterEncoding.

	"(aFileReference basename = #'moduleAtRoot12.py') ifTrue: [ 1halt ]."

	FamixTSRootNodeWrapper new
		tsNode: tree rootNode;
		accept: visitor
]

{ #category : 'importing' }
FamixTSAbstractImporter >> importFileReference: aFileReference [
	"This will depend on the language we are parsing.
	This should call #importFile: when the file reference is a file."

	self subclassResponsibility
]

{ #category : 'initialization' }
FamixTSAbstractImporter >> initializeVisitorAndModel [

	visitor := self visitorClass new.

	self model
		name: rootReference basename;
		rootFolder: (rootReference isFile
				 ifTrue: [ rootReference parent ]
				 ifFalse: [ rootReference ]) "If we parse a folder, it will be the root. If it's just a file, we consider that the root is its parent"
]

{ #category : 'importing' }
FamixTSAbstractImporter >> manageErrorReport [

	^ self errorReport ifNotEmpty: [ self errorReport inspect ]
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> model [

	^ visitor model
]

{ #category : 'importing' }
FamixTSAbstractImporter >> preparsingHook [
	"Do nothing by default but this can be useful for some importers."

	
]

{ #category : 'asserting' }
FamixTSAbstractImporter >> shouldCheckForDuplicatedEntitiesInCollections [
	"If I return true, them all FMMany slots of the MooseModel will ensure that each entity added is be unique in collections. 
	But most parsers should not add duplicated elements. So I'm disabling this check by default for performance reasons."

	^ false
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> treeSitterLanguage [
	"Should return a TreeSitter language such as  TSLanguage python"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> visitor [

	^ visitor
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> visitorClass [
	"Return the class of the visitor to use. It should be a subclass of FamixTSAbstractVisitor."

	^ self subclassResponsibility
]
