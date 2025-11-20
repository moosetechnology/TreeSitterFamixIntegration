# TreeSitterFamixIntegration

I am a project whose aim is to help to build Famix importers based on TreeSitter

## Installation

To install the project in your Pharo image execute:

```Smalltalk
    Metacello new
    	githubUser: 'moosetechnology' project: 'TreeSitterFamixIntegration' commitish: 'main' path: 'src';
    	baseline: 'TreeSitterFamixIntegration';
    	load
```

To add it to your baseline:

```Smalltalk
    spec
    	baseline: 'TreeSitterFamixIntegration'
    	with: [ spec repository: 'github://moosetechnology/TreeSitterFamixIntegration:main/src' ]
```

Note that you can replace the #master by another branch such as #development or a tag such as #v1.0.0, #v1.? or #v1.1.?.

## Documentation 

Full documentation available at: [User documentation](resources/docs/UserDocumentation.md)

## Testing

This project is not easy to test by itself so the testing is not happening here for real. 
I am trying to test all parts of this project as part of the [Moose Python importer](https://github.com/moosetechnology/MoosePy).
