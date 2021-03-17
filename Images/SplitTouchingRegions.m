pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));


face1 = LoadFace(pathToTemplate);
face2 = LoadFace(pathToTemplate);

[numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);


face1.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face1.nVertices, 1);
face1.VertexRGB(indicesByRegion{1}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{1}), 1);
face1.VertexRGB(indicesByRegion{5}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{5}), 1);
face1.VertexRGB(indicesByRegion{8}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{8}), 1);
face1.VertexRGB(indicesByRegion{9}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{9}), 1);
face1.ColorMode = 'texture';

v1 = DrawFace(face1, "Obraz 1", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [0, 0, 180];
saveas(v1.Figure, 'SplitTouchingRegionsBefore.png');


face2.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face2.nVertices, 1);
face2.VertexRGB(indicesByRegion{1}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{1}), 1);
face2.VertexRGB(indicesByRegion{5}, :) = repmat([255, 0, 0] / 255, length(indicesByRegion{5}), 1);
face2.VertexRGB(indicesByRegion{8}, :) = repmat([0, 0, 255] / 255, length(indicesByRegion{8}), 1);
face2.VertexRGB(indicesByRegion{9}, :) = repmat([0, 0, 255] / 255, length(indicesByRegion{9}), 1);
face2.ColorMode = 'texture';

v2 = DrawFace(face2, "Obraz 2", false);
v2.SceneLightVisible = true;
v2.SceneLightLinked = true;
v2.CameraTarget = [0, 0, 0];
v2.CameraUpVector = [0, 1, 0];
v2.SceneLightPosition = [0, 0, 180];
v2.CameraPosition = [0, 0, 180];
saveas(v2.Figure, 'SplitTouchingRegionsAfter.png');