Class {
	#name : 'FamixTSAbstractImporter',
	#superclass : 'Object',
	#instVars : [
		'visitor'
	],
	#category : 'TreeSitter-Famix-Integration',
	#package : 'TreeSitter-Famix-Integration'
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

{ #category : 'accessing' }
FamixTSAbstractImporter >> import: aFileReference [

	| fileReference |
	"In case the user provided a file name instead of a file reference.""We should probably handle it another way in production."
	fileReference := aFileReference asFileReference.
	self initializeVisitorAndModelUsing: fileReference.
	self importFileReference: fileReference.
	visitor resolveUnresolvedSymbols.
	self manageErrorReport.
	^ visitor model
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> importFile: aFileReference [

	| parser tree |
	('Importing ' , aFileReference pathString) traceCr.

	parser := TSParser new.
	parser language: self treeSitterLanguage.

	visitor fileReference: aFileReference.
	tree := parser parseString: visitor sourceText.

	"(aFileReference basename = #'moduleAtRoot8.py') ifTrue: [ 1halt ]."

	self flag: #todo. "A tool to list possible nodes, possible parents and possible children"
	FamixTSRootNodeWrapper new
		tsNode: tree rootNode;
		accept: visitor
]

{ #category : 'accessing' }
FamixTSAbstractImporter >> importFileReference: aFileReference [
	"This will depend on the language we are parsing.
	This should call #importFile: when the file reference is a file."

	self subclassResponsibility
]

{ #category : 'as yet unclassified' }
FamixTSAbstractImporter >> initializeVisitorAndModelUsing: aFileReference [

	visitor := self visitorClass new.

	visitor model
		name: aFileReference basename;
		rootFolder: (aFileReference isFile
				 ifTrue: [ aFileReference parent ]
				 ifFalse: [ aFileReference ]) "If we parse a folder, it will be the root. If it's just a file, we consider that the root is its parent"
]

{ #category : 'as yet unclassified' }
FamixTSAbstractImporter >> manageErrorReport [

	^ self errorReport ifNotEmpty: [ self errorReport inspect ]
]

{ #category : 'as yet unclassified' }
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
