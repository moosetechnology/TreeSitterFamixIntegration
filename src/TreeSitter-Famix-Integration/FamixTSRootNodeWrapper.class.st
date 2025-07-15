Class {
	#name : 'FamixTSRootNodeWrapper',
	#superclass : 'FamixTSNodeWrapper',
	#instVars : [
		'relativePath',
		'completeSource'
	],
	#category : 'TreeSitter-Famix-Integration',
	#package : 'TreeSitter-Famix-Integration'
}

{ #category : 'visiting' }
FamixTSRootNodeWrapper >> accept: aVisitor [

	self
		relativePath: aVisitor relativeFilePath;
		completeSource: aVisitor sourceText.
	super accept: aVisitor
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> completeSource [

	^ completeSource
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> completeSource: aString [
	completeSource := aString
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> relativePath [

	^ relativePath
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> relativePath: anObject [

	relativePath := anObject
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> rootNode [

	^ self
]
