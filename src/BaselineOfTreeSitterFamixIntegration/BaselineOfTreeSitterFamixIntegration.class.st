"
I am a baseline to define the structure and dependencies of the TreeSitterFamixIntegration project.
"
Class {
	#name : 'BaselineOfTreeSitterFamixIntegration',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTreeSitterFamixIntegration',
	#package : 'BaselineOfTreeSitterFamixIntegration'
}

{ #category : 'baselines' }
BaselineOfTreeSitterFamixIntegration >> baseline: spec [

	<baseline>
	spec for: #common do: [ "Dependencies"
			self
				treeSitter: spec;
				symbolResolver: spec.

			"Packages"
			spec package: 'TreeSitter-Famix-Integration' with: [ spec requires: #( TreeSitter SymbolResolver ) ] ]
]

{ #category : 'accessing' }
BaselineOfTreeSitterFamixIntegration >> projectClass [
	^ MetacelloCypressBaselineProject
]

{ #category : 'dependencies' }
BaselineOfTreeSitterFamixIntegration >> symbolResolver: spec [

	spec baseline: 'SymbolResolver' with: [ spec repository: 'github://jecisc/SymbolResolver:main/src' ]
]

{ #category : 'dependencies' }
BaselineOfTreeSitterFamixIntegration >> treeSitter: spec [

	spec baseline: 'TreeSitter' with: [ spec repository: 'github://Evref-BL/Pharo-Tree-Sitter:main/src' ]
]
