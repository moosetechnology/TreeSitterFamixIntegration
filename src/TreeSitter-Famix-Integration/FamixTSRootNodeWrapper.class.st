Class {
	#name : 'FamixTSRootNodeWrapper',
	#superclass : 'FamixTSNodeWrapper',
	#instVars : [
		'visitor',
		'completeSource',
		'relativePath'
	],
	#category : 'TreeSitter-Famix-Integration',
	#package : 'TreeSitter-Famix-Integration'
}

{ #category : 'visiting' }
FamixTSRootNodeWrapper >> accept: aVisitor [

	self visitor: aVisitor.
	super accept: aVisitor
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> completeSource [

	^ completeSource
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> relativePath [

	^ relativePath
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> rootNode [

	^ self
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> visitor [

	^ visitor
]

{ #category : 'accessing' }
FamixTSRootNodeWrapper >> visitor: anObject [

	visitor := anObject.
	completeSource := visitor sourceText.
	relativePath := visitor relativeFilePath
]
