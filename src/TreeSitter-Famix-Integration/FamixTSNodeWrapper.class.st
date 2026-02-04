"
I am a wrapper of TSNodes to access more info and keep the children/parents of each nodes. Check the github documentation for more info.
"
Class {
	#name : 'FamixTSNodeWrapper',
	#superclass : 'Object',
	#instVars : [
		'tsNode',
		'parent',
		'children',
		'sourceText',
		'startPosition',
		'type'
	],
	#category : 'TreeSitter-Famix-Integration-Wrappers',
	#package : 'TreeSitter-Famix-Integration',
	#tag : 'Wrappers'
}

{ #category : 'visiting' }
FamixTSNodeWrapper >> accept: aTSVisitor [

	^ aTSVisitor visitNode: self
]

{ #category : 'api' }
FamixTSNodeWrapper >> collectFieldNameOfNamedChild [

	^ children ifNil: [
			  children := tsNode collectFieldNameOfNamedChild.

			  children associationsDo: [ :association |
					  | value |
					  value := association value.
					  association value: (value isCollection
							   ifTrue: [
									   value collect: [ :node |
											   FamixTSNodeWrapper new
												   tsNode: node;
												   parent: self;
												   yourself ] ]
							   ifFalse: [
									   FamixTSNodeWrapper new
										   tsNode: value;
										   parent: self;
										   yourself ]) ].
			  children ]
]

{ #category : 'api' }
FamixTSNodeWrapper >> collectNamedChild [

	^ self collectFieldNameOfNamedChild values flattened
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> completeSource [

	^ self rootNode completeSource
]

{ #category : 'collection' }
FamixTSNodeWrapper >> detectNamedChild: name ifNone: aConstantBlockClosure [

	^ self collectNamedChild
		  detect: [ :node | node type = name ]
		  ifNone: aConstantBlockClosure
]

{ #category : 'reflective operations' }
FamixTSNodeWrapper >> doesNotUnderstand: aMessage [
	"Forward message to decoree except if it's a node by field access"

	aMessage selector first = $_ ifTrue: [ ^ self nodeChildByFieldName: aMessage selector allButFirst ifAbsent: [ nil ] ].

	^ aMessage sendTo: tsNode
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> encoding [

	^ self parent encoding
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> endPosition [
	"Return the end position of the node in number of characters.
	
	Instead of reading multiple times the file we use the cache of #startPosition and #sourceText."

	^ self startPosition + self sourceText size - 1
]

{ #category : 'inspector' }
FamixTSNodeWrapper >> fieldsInspectorExtension: aBuilder [

	<inspectorPresentationOrder: 900.5 title: 'Fields'>
	^ aBuilder newTable
		  addStyle: 'stList';
		  addColumn: (SpStringTableColumn new
				   title: 'Key';
				   evaluated: [ :each | each key ];
				   formatted: [ :key | StObjectPrinter asTruncatedTextFrom: key ];
				   beSortable);
		  addColumn: (SpStringTableColumn new
				   title: 'Value';
				   evaluated: [ :each | each value ];
				   formatted: [ :value | StObjectPrinter asTruncatedTextFrom: value ];
				   beSortable);
		  items: (self collectFieldNameOfNamedChild associations collect: [ :e | StInspectorAssociationNode hostObject: e ]);
		  yourself
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> fileReference [

	^ self parent fileReference
]

{ #category : 'inspector' }
FamixTSNodeWrapper >> fullSourceInspectorExtension: aBuilder [

	<inspectorPresentationOrder: 902 title: 'Full source'>
	^ aBuilder newCode
		  withoutSyntaxHighlight;
		  withLineNumbers;
		  text: self completeSource asString;
		  addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
				   interval: (self startPosition to: self endPosition + 1);
				   yourself);
		  beNotEditable
]

{ #category : 'testing' }
FamixTSNodeWrapper >> includesChild: aNode [
	"Return true if I includes the parameter in my chlidren recursively."

	self = aNode ifTrue: [ ^ true ].
	^ self collectNamedChild
		  detect: [ :node | node = aNode or: [ node includesChild: aNode ] ]
		  ifFound: [ :node | true ]
		  ifNone: [ false ]
]

{ #category : 'testing' }
FamixTSNodeWrapper >> isInField: aName ofParentOfType: aType [
	"Return true if I have a parent of the type `aType` recursively, and I am in the field `aName` of this node recursively.
	
	Exemple: `aNode isInField: #body ofParentOfType: #list_comprehension
	
	It will return true if the node is in the field body of a list comprehension. "

	self parentsDo: [ :node |
			node type = aType ifTrue: [
					^ node
						  nodeChildByFieldName: aName
						  ifPresent: [ :field |
								  field isCollection
									  ifTrue: [ field anySatisfy: [ :f | f includesChild: self ] ]
									  ifFalse: [ field includesChild: self ] ]
						  ifAbsent: [ false ] ] ].
	^ false
]

{ #category : 'testing' }
FamixTSNodeWrapper >> isTSNode [

	^ true
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> nodeChildByFieldName: aName [

	^ self collectFieldNameOfNamedChild at: aName
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> nodeChildByFieldName: aName ifAbsent: aBlock [

	^ self collectFieldNameOfNamedChild at: aName ifAbsent: aBlock
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> nodeChildByFieldName: aName ifPresent: block ifAbsent: aBlock [

	^ self collectFieldNameOfNamedChild
		  at: aName
		  ifPresent: block
		  ifAbsent: aBlock
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> parent [

	^ parent
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> parent: anObject [

	parent := anObject
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> parentOfType: aSymbol [

	self parentsDo: [ :node | node type = aSymbol ifTrue: [ ^ node ] ].

	^ nil
]

{ #category : 'enumerating' }
FamixTSNodeWrapper >> parentsDo: aBlock [

	^ self parent ifNotNil: [ :parentNode |
			  aBlock value: parentNode.
			  parentNode parentsDo: aBlock ]
]

{ #category : 'printing' }
FamixTSNodeWrapper >> printOn: aStream [

	aStream nextPutAll: 'Wrapped: '.
	tsNode printOn: aStream
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> relativePath [

	^ self rootNode relativePath
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> rootNode [
	^ self parent rootNode
]

{ #category : 'inspector' }
FamixTSNodeWrapper >> sourceInspectorExtension: builder [

	<inspectorPresentationOrder: 901 title: 'Source'>
	^ builder newCode
		  withoutSyntaxHighlight;
		  withLineNumbers;
		  text: self sourceText;
		  beNotEditable
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> sourceText [
	"We don't need the buffered stream so we use the wrapped stream for speed."

	^ sourceText ifNil: [ sourceText := self fileReference binaryReadStreamDo: [ :stream | tsNode textFrom: stream wrappedStream encoding: self encoding ] ]
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> startPosition [
	"Return the start position of the node in number of characters.
	
	We don't need the buffered stream so we use the wrapped stream for speed."

	^ startPosition ifNil: [
		  startPosition := self fileReference binaryReadStreamDo: [ :stream | tsNode startPositionFrom: stream wrappedStream encoding: self encoding ] ]
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> tsNode [

	^ tsNode
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> tsNode: anObject [

	tsNode := anObject
]

{ #category : 'inspector' }
FamixTSNodeWrapper >> tsTreeExtension: builder [

	<inspectorPresentationOrder: 15 title: 'TS Tree'>
	^ (builder instantiate: SpTreeTablePresenter)
		  addColumn: (SpCompositeTableColumn new
				   addColumn: (SpStringTableColumn evaluated: #type);
				   yourself);
		  children: [ :aTSNode | aTSNode collectNamedChild ];
		  roots: { self };
		  beResizable;
		expandAll
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> type [
	"Cache to avoid stressing too much FFI"

	^ type ifNil: [ type := tsNode type ]
]

{ #category : 'accessing' }
FamixTSNodeWrapper >> visitor [
	^ self rootNode visitor
]
