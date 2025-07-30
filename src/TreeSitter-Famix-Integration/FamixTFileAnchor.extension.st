Extension { #name : 'FamixTFileAnchor' }

{ #category : '*TreeSitter-Famix-Integration' }
FamixTFileAnchor >> includesInterval: anInterval [

	anInterval first >= self startPos ifFalse: [ ^ false ].

	^ anInterval last <= self endPos
]

{ #category : '*TreeSitter-Famix-Integration' }
FamixTFileAnchor >> numberOfCharacters [

	^ self endPos - self startPos
]
