pathToTemplate = 'Data/template.obj';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

face1 = LoadFace(pathToTemplate);

incorrectVerts = csvread('../Data/template_swapped_verts.txt');
middleVerts = csvread('../Data/template_middle_verts.txt');

incorrectVerts = setdiff(incorrectVerts, middleVerts);

face1.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face1.nVertices, 1);
face1.VertexRGB(incorrectVerts, :) = repmat([255, 0, 0] / 255, length(incorrectVerts), 1);
face1.ColorMode = 'texture';


v1 = DrawFace(face1, "Obraz", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [0, 0, 180];
saveas(v1.Figure, 'ColorIncorrectSymmetryFace.png');