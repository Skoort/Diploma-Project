pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = '../Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

[numFaces, faces] = LoadFaces(pathToFaces);
[numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);

numMergedFaces = 4;
[chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces);

[numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);

splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);

splicedFace.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, splicedFace.nVertices, 1);
splicedFace.ColorMode = 'texture';

v1 = DrawFace(splicedFace, "Prvotni kolaz", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [0, 0, 180];


% Run after with different interps
INTERP_AMOUNT = 0;


shouldAverageWeights = true;


collageFace = MergeSmooth(faces, splicedFace.clone(), numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights);  % <- Done


collageFace = MeshFit2(collageFace);

symmetryFactor = 0.9;
collageFace2 = IntroduceSymmetry(collageFace, symmetryFactor);


smoothSymmetryFace = AverageFace(collageFace2);


interpolatedFace = InterpFace(splicedFace, smoothSymmetryFace, INTERP_AMOUNT);  % <- Done
interpolatedFace.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, splicedFace.nVertices, 1);
interpolatedFace.ColorMode = 'texture';

v1 = DrawFace(interpolatedFace, "Obraz", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [0, 0, 180];
saveas(v1.Figure, 'Images/DifferentInterps0.png');
