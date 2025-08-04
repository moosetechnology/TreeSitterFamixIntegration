Extension { #name : 'String' }

{ #category : '*TreeSitter-Famix-Integration' }
String >> hasNoLineReturnBetween: start and: end [

	^ (self copyFrom: start to: end) noneSatisfy: [ :character | character = Character lf or: [ character = Character cr ] ]
]

{ #category : '*TreeSitter-Famix-Integration' }
String >> hasOnlySpacesAndTabsBetween: start and: end [

	^ (self copyFrom: start to: end) allSatisfy: [ :character | character isSpaceSeparator or: [ character = Character tab ] ]
]
