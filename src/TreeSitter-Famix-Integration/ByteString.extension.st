Extension { #name : 'ByteString' }

{ #category : '*TreeSitter-Famix-Integration' }
ByteString >> hasNoLineReturnBetween: start and: end [

	^ (self copyFrom: start to: end) noneSatisfy: [ :character | character = Character lf or: [ character = Character cr ] ]
]

{ #category : '*TreeSitter-Famix-Integration' }
ByteString >> hasOnlySpacesAndTabsBetween: start and: end [

	^ (self copyFrom: start to: end) allSatisfy: [ :character | character isSpaceSeparator or: [ character = Character tab ] ]
]
