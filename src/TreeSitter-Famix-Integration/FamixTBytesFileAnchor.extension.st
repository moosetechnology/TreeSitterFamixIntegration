Extension { #name : 'FamixTBytesFileAnchor' }

{ #category : '*TreeSitter-Famix-Integration' }
FamixTBytesFileAnchor >> includesInterval: anInterval [

	anInterval first >= self startByte ifFalse: [ ^ false ].

	^ anInterval last <= self endByte
]

{ #category : '*TreeSitter-Famix-Integration' }
FamixTBytesFileAnchor >> numberOfBytes [

	^ self endByte - self startByte
]
