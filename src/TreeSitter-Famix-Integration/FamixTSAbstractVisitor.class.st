Class {
	#name : 'FamixTSAbstractVisitor',
	#superclass : 'TSVisitor',
	#traits : 'SRTSolverUserVisitor',
	#classTraits : 'SRTSolverUserVisitor classTrait',
	#instVars : [
		'fileReference',
		'model',
		'commentsImporter'
	],
	#category : 'TreeSitter-Famix-Integration',
	#package : 'TreeSitter-Famix-Integration'
}

{ #category : 'private' }
FamixTSAbstractVisitor >> buildVisitMethodNameFor: aTSNode [

	^ (String streamContents: [ :aStream |
			   aStream nextPutAll: 'visit'.
			   ($_ split: aTSNode type) do: [ :word | aStream nextPutAll: word capitalized ].
			   aStream nextPut: $: ]) asSymbol
]

{ #category : 'reflective operations' }
FamixTSAbstractVisitor >> doesNotUnderstand: aMessage [

	(aMessage selector beginsWith: 'visit') ifTrue: [
			('Not implemented visit method: ' , aMessage selector) traceCr.
			super visitNode: aMessage argument ].

	^ super doesNotUnderstand: aMessage
]

{ #category : 'accessing' }
FamixTSAbstractVisitor >> fileReference [

	^ fileReference
]

{ #category : 'accessing' }
FamixTSAbstractVisitor >> fileReference: anObject [

	fileReference := anObject
]

{ #category : 'initialization' }
FamixTSAbstractVisitor >> initialize [

	super initialize.
	model := self modelClass new name: 'Default Model Name'.
	model sourceLanguage: model newSourceLanguage.
	self initialiseSolver
]

{ #category : 'accessing' }
FamixTSAbstractVisitor >> model [

	^ model
]

{ #category : 'accessing' }
FamixTSAbstractVisitor >> modelClass [
	"Should return the model class such as FamixPythonModel."

	^ self subclassResponsibility
]

{ #category : 'private' }
FamixTSAbstractVisitor >> relativeFilePath [

	self model rootFolder ifNil: [ ^ self fileReference fullName removePrefix: '/' ].

	^ (self fileReference relativeTo: self model rootFolder asPath) pathString
]

{ #category : 'private' }
FamixTSAbstractVisitor >> setSourceAnchor: aFamixEntity from: aTSNode [

	^ self
		  setSourceAnchorTo: aFamixEntity
		  fileName: aTSNode relativePath
		  start: aTSNode startPosition
		  end: aTSNode endPosition
]

{ #category : 'private' }
FamixTSAbstractVisitor >> setSourceAnchorTo: aFamixEntity fileName: aString start: aNumber end: anotherNumber [

	aFamixEntity sourceAnchor: (model newIndexedFileAnchor
			 fileName: aString;
			 startPos: aNumber;
			 endPos: anotherNumber;
			 mooseModel: self model;
			 yourself).

	(aFamixEntity class includesTrait: FamixTCanBeStub) ifTrue: [ aFamixEntity isStub: false ].

	^ aFamixEntity
]

{ #category : 'accessing' }
FamixTSAbstractVisitor >> sourceText [

	self flag: #todo. "Manage encorders."
	^ self fileReference contents
]

{ #category : 'visiting' }
FamixTSAbstractVisitor >> visit: anObject [

	anObject isTSNode ifTrue: [ ^ self visitNode: anObject ].
	anObject isCollection ifTrue: [ ^ self visitNodes: anObject ].
	^ anObject
]

{ #category : 'visiting' }
FamixTSAbstractVisitor >> visitChildren: aTSNode [

	^ aTSNode collectNamedChild collect: [ :child | child accept: self ]
]

{ #category : 'visiting' }
FamixTSAbstractVisitor >> visitNode: aTSNode [
	"Here we are performing a special visit method. If it is not implemented the #doesNotUnderstood: will call my super visitNode:. The reason we are doing this is to simplify the debugging of a visitor to not have to step over a lot of method calls..."

	^ self errorReport catch: Exception during: [ self perform: (self buildVisitMethodNameFor: aTSNode) with: aTSNode ]
]

{ #category : 'visiting' }
FamixTSAbstractVisitor >> visitNodes: aCollection [

	^ aCollection collect: [ :node | self visit: node ]
]
