"
I am a simple visitor to help find some patterns in a project. 

I'll parse all files of the project and you can configure me to stop if I find a certain pattern.
"
Class {
	#name : 'FamixTSDebugVisitor',
	#superclass : 'TSVisitor',
	#instVars : [
		'language',
		'extensions',
		'stopBlock',
		'filesToParse',
		'sourceText'
	],
	#category : 'TreeSitter-Famix-Integration-Core',
	#package : 'TreeSitter-Famix-Integration',
	#tag : 'Core'
}

{ #category : 'instance creation' }
FamixTSDebugVisitor class >> cStopIf: aBlock visit: aFileReference [

	^ self new
		  language: TSLanguage cLang;
		  extensions: #( 'c' 'h' );
		  stopBlock: aBlock;
		  visit: aFileReference
]

{ #category : 'instance creation' }
FamixTSDebugVisitor class >> language: aTSLanguage extensions: aCollection stopIf: aBlock visit: aFileReference [

	^ self new
		  language: aTSLanguage;
		  extensions: aCollection;
		  stopBlock: aBlock;
		  visit: aFileReference 
]

{ #category : 'instance creation' }
FamixTSDebugVisitor class >> pythonStopIf: aBlock visit: aFileReference [

	^ self new
		  language: TSLanguage python;
		  extensions: #( 'py' );
		  stopBlock: aBlock;
		  visit: aFileReference
]

{ #category : 'initialization' }
FamixTSDebugVisitor >> collectFilesIn: aFileReference [

	^ aFileReference isFile
		  ifTrue: [ (self extensions includes: aFileReference extension) ifTrue: [ filesToParse add: aFileReference ] ]
		  ifFalse: [ aFileReference children do: [ :child | self collectFilesIn: child ] ]
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> extensions [
	^ extensions
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> extensions: anObject [
	extensions := anObject
]

{ #category : 'initialization' }
FamixTSDebugVisitor >> initialize [

	super initialize.
	filesToParse := OrderedCollection new
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> language [
	^ language
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> language: anObject [
	language := anObject
]

{ #category : 'private' }
FamixTSDebugVisitor >> relativeFilePath [
	"No need of this here."

	^ nil
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> sourceText [
	^ sourceText
]

{ #category : 'accessing' }
FamixTSDebugVisitor >> stopBlock: anObject [
	stopBlock := anObject
]

{ #category : 'visiting' }
FamixTSDebugVisitor >> visit: aFileReference [

	self collectFilesIn: aFileReference.

	filesToParse
		do: [ :file |
				| tree |
				sourceText := file contents.
				tree := (TSParser language: self language) parseString: sourceText.

				FamixTSRootNodeWrapper new
					tsNode: tree rootNode;
					accept: self ]
		displayingProgress: [ :file | file pathString ]
]

{ #category : 'visiting' }
FamixTSDebugVisitor >> visitNode: aNode [

	self haltIf: [ stopBlock value: aNode ].
	super visitNode: aNode
]
