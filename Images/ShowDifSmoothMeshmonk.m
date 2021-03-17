IMAGE_NUMBER = 4;

pathToAverage = '../Data/average.obj';
pathToTemplate = '../Data/template.obj';
pathToRegions = "../Data/template_color.ply";
pathToFaces = '../Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

%
averageFace = LoadFace(pathToAverage);
%
template = LoadFace(pathToTemplate);
[numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);
%
[numFaces, faces] = LoadFaces(pathToFaces);
%%numFaces = 10;

numMergedFaces = 6;
[chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces);

shouldFilterRegions = true;
if shouldFilterRegions
    [numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);
end

splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);
%SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion);


mergeOptions = ["MERGE_SIMPLE", "MERGE_SMOOTH_DIST", "MERGE_3"];
selectedMergeOption = 3;
shouldAverageWeights = true;

if selectedMergeOption == 1
    maxDistanceToSmooth = 2;
    collageFace = MergeSimple(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 2
    maxDistanceToSmooth = 0.25;
    collageFace = MergeSimplePercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 3
    % NOTE: Not using distance here.
    collageFace = MergeSmooth(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, 4);  % <- Done
elseif selectedMergeOption == 4
    maxDistanceToSmooth = 1;
    collageFace = MergeSmoothPercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 5
    collageFace = Merge3(splicedFace, shouldAverageWeights);  % <- To implement.
else
    warning("Incorrect merge option selected!");
end

collageFace.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, collageFace.nVertices, 1);
collageFace.ColorMode = 'texture';
v1 = DrawFace(collageFace, "Obraz", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [80, 0, 80];
saveas(v1.Figure, ['ShowDifBeforeMeshmonk', num2str(IMAGE_NUMBER), '.png']);

numFits = 1;
for i=1:numFits
    collageFace = MeshFit2(collageFace);  % <- Done
end

collageFace.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, collageFace.nVertices, 1);
collageFace.ColorMode = 'texture';
v2 = DrawFace(collageFace, "Obraz", false);
v2.SceneLightVisible = true;
v2.SceneLightLinked = true;
v2.CameraTarget = [0, 0, 0];
v2.CameraUpVector = [0, 1, 0];
v2.SceneLightPosition = [0, 0, 180];
v2.CameraPosition = [80, 0, 80];
saveas(v2.Figure, ['ShowDifAfterMeshmonk', num2str(IMAGE_NUMBER), '.png']);