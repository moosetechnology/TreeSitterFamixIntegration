"
I am the base a TreeSitter visitor to import comments of a project.

I need to be subclasses so that #visitNode: is reimplemented in a way to find the comment intervals in the tree. Then I manage the comments.

I transform these positions into comment entities attached to the right entity in the file.

I'll check multiple things:
- If single line comments follow each other I'll merge them
- If a comment is one line before the declaration of an entity, I'll attach it to this entity
- If a comment is on the smae line than the declaration of a variable I'll attach it to this entity
- If a comment is just inside an entity, I'll attach it to it
"
Class {
	#name : 'FamixTSAbstractCommentsVisitor',
	#superclass : 'TSVisitor',
	#instVars : [
		'visitor',
		'entitiesInFile',
		'singleLineIntervals',
		'multilineIntervals'
	],
	#category : 'TreeSitter-Famix-Integration-Core',
	#package : 'TreeSitter-Famix-Integration',
	#tag : 'Core'
}

{ #category : 'instance creation' }
FamixTSAbstractCommentsVisitor class >> visitor: aFamixPythonVisitor importCommentsOf: aNode [

	^ self new
		  visitor: aFamixPythonVisitor;
		  visitNode: aNode;
		  import
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> addMultilineCommentNode: aNode [

	multilineIntervals add: (self intervalOf: aNode)
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> addSingleLineCommentNode: aNode [

	singleLineIntervals add: (self intervalOf: aNode)
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> computeEntitiesInCurrentFile [
	"This is a generic implementation but it can be overriden"

	^ visitor currentEntity withAllContainedEntities
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> createCommentFor: anEntity from: start to: stop [

	| comment |
	comment := self model newComment.
	comment commentedEntity: anEntity.
	visitor
		setSourceAnchorTo: comment
		fileName: visitor relativeFilePath
		start: start
		end: stop.
	^ comment
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> createMultilineCommentFromInterval: commentInterval [ 

	"Before checking if the comment is inside an entity, we check that it is not right before the declaration of an entity."
	(self entityFollowingComment: commentInterval) ifNotNil: [ :entity | ^ self createCommentFor: entity from: commentInterval first to: commentInterval second ].

	^ self entitiesInFile
		  detect: [ :entity | entity sourceAnchor includesInterval: commentInterval ]
		  ifFound: [ :entity | self createCommentFor: entity from: commentInterval first to: commentInterval second ]
		  ifNone: [ self error: 'All comments should be at least in the top module/package.' ]
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> createSingleLineCommentFromInterval: commentInterval [

	"First we look for comments that are right after the declaration of an entity on the same line."
	(self entityOnLineOfComment: commentInterval) ifNotNil: [ :entity | ^ self createCommentFor: entity from: commentInterval first to: commentInterval second ].

	"Before checking if the comment is inside an entity, we check that it is not right before the declaration of an entity."
	(self entityFollowingComment: commentInterval) ifNotNil: [ :entity | ^ self createCommentFor: entity from: commentInterval first to: commentInterval second ].

	^ self entitiesInFile
		  detect: [ :entity | entity sourceAnchor includesInterval: commentInterval ]
		  ifFound: [ :entity | self createCommentFor: entity from: commentInterval first to: commentInterval second ]
		  ifNone: [ self error: 'All comments should be at least in the top module/package.' ]
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> entitiesInFile [
	"Sorting by the number of characters allows us to have the most atomic entities first. Imagine we have an inner function in a function. If a comment is an the inner function, it is also in the function containing it. So we want to check the inner function first because it's the most inner entity that should have the comment attached."

	^ entitiesInFile ifNil: [
			  entitiesInFile := (self computeEntitiesInCurrentFile select: [ :entity | entity sourceAnchor isNotNil ]) sorted:
				                    [ :entity | entity sourceAnchor numberOfCharacters ] ascending ]
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> entityFollowingComment: commentInterval [
	"Return an entity declared right after the comment. For example:
	
	```
	# Function doing things
	def function():
	  pass
	```
	"
	"Take the entity right after the comment"
	((self entitiesInFile select: [ :entity | entity sourceAnchor startPos > commentInterval second ]) detectMin: [ :entity | entity sourceAnchor startPos ])
		ifNotNil: [ :entity | (self source hasOnlySpacesAndTabsBetween: commentInterval second + 1 and: entity sourceAnchor startPos - 1) ifTrue: [ ^ entity ] ].
	^ nil
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> entityOnLineOfComment: commentInterval [
	"We check if the comment is on the same line than a variable declaration such as:
	
	`var = 31 # Number of bytes`
	"

	"Take the entity right before the comment"

	((self entitiesInFile select: [ :entity | entity isStructuralEntity and: [ entity sourceAnchor endPos < commentInterval first ] ]) detectMax: [ :entity | "We take the start because comments are not considered part of the entites so we might have multiple entities with the same end pos if they are imbricated."
		 entity sourceAnchor startPos ]) ifNotNil: [ :entity |
		(self source hasNoLineReturnBetween: entity sourceAnchor endPos + 1 and: commentInterval first - 1) ifTrue: [ ^ entity ] ].

	^ nil
]

{ #category : 'actions' }
FamixTSAbstractCommentsVisitor >> import [
	"Comments are not represented by nodes in SmaCC. A FileNode can return the intervals of the comments so we need to find to whose entity those comments are attached to.
	I also save strings that are comments into the #multilineComments property."

	singleLineIntervals ifNotEmpty: [
			| intervals |
			"If we have two single line comments following each other, we can merge them."
			intervals := OrderedCollection new.
			singleLineIntervals do: [ :interval |
					intervals ifEmpty: [ intervals add: interval ] ifNotEmpty: [ "We can merge if we have only spaces and tabs between the comments."
							(self source hasOnlySpacesAndTabsBetween: intervals last second + 1 and: interval first - 1)
								ifTrue: [ intervals last at: 2 put: interval second ]
								ifFalse: [ intervals add: interval ] ] ].

			intervals do: [ :commentInterval | visitor errorReport catch: Exception during: [ self createSingleLineCommentFromInterval: commentInterval ] ] ].

	multilineIntervals do: [ :interval | visitor errorReport catch: Exception during: [ self createMultilineCommentFromInterval: interval ] ]
]

{ #category : 'initialization' }
FamixTSAbstractCommentsVisitor >> initialize [

	super initialize.
	
	"It happens that we have comments in a random order but we need to be sure they are in the order of the file in order for our algos to work well.
	So we sort them by their start position in the file."
	singleLineIntervals := SortedCollection sortUsing: #first ascending.
	multilineIntervals := SortedCollection sortUsing: #first ascending
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> intervalOf: aNode [

	^ {
		  aNode startPosition.
		  (aNode rootNode endPosition min: aNode endPosition + 1) "Take the line return. This might not work on files from windows since it's CRLF also we can have spaces before the line return. We should maybe do something more robust. Also, do not take it of we are at the end of the file." }
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> model [

	^ self visitor model
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> source [
	^ visitor sourceText
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> visitor [

	^ visitor
]

{ #category : 'accessing' }
FamixTSAbstractCommentsVisitor >> visitor: anObject [

	visitor := anObject
]
