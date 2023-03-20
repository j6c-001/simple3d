
The Simple 3D package is a very (very) simple 3D rendering framework.

## Features

- Supports definition and rendering of very basic 3D models. Model definitions can be instanced as many times as needed. 
- Simple 3D batches the triangles that make up models into  a single drawVertices call so it is quite efficient.
- Works well on web in addition to native platforms.

## Anti Features
- lighting and shadows etc. are not supported at this time.

## Getting started

Have a look at the demos below.

Define as many ```View3d``` instances as you want. Each instance is like a specific view on a scene. It draws all
the models it knows about whenever ```View3d.render()``` is called. 

Define a ```VertexModel``` using the helper function ```makeVertexModel```
Create an instance of the model with VertexModelInstance, and use 

Use ```VertextModelInstance.prepareFrame()``` to tell a view the current position and orientation.

## Usage

Basic Usage demonstrating multiple viewports
- https://github.com/j6c-001/drawing

Demo integrated with the Flame Engine
- https://github.com/j6c-001/badboids

Basic Model Definition
```dart
final aBox =  makeVertexModel([
  [ /// These are your vertices defined in model space.
    [-1, 1, -1], // 0
    [ 1, 1, -1], // 1
    [ 1, 1,  1], // 2
    [-1, 1,  1], // 3
    [-1, -1, -1], // 4
    [ 1, -1, -1], // 5
    [1, -1,  1], // 6
    [-1, -1,  1], // 7
  ]    ,  [ /// these are the triangles built from color the vertex indices 
    [Colors.red, [0, 1, 2]],
    [Colors.green, [0,2,3]],
    
    [Colors.red, [4, 5, 6]],
    [Colors.green, [4,6,7]],
    
    [Colors.red, [0, 3, 7]],
    [Colors.green, [0, 4, 7]],


    [Colors.red, [3, 6, 7]],
    [Colors.green, [2, 3, 6]],

    [Colors.red, [4, 5, 0]],
    [Colors.green, [5, 1, 0]],
    
    [Colors.red, [1, 2, 6]],
    [Colors.green, [1, 6, 5]],
    
  ]
]);
```

## Additional information

This is a personal project for fun!
