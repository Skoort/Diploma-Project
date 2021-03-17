
pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

%
averageFace = LoadFace(pathToAverage);
%
template = LoadFace(pathToTemplate);
[numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);
%
[numFaces, faces] = LoadFaces(pathToFaces);
%%numFaces = 10;

numMergedFaces = 4;
[chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces);

numRegions2 = numRegions;
regionByIndex2 = regionByIndex;
indicesByRegion2 = indicesByRegion;
chosenFacesByRegion2 = chosenFacesByRegion;
shouldFilterRegions = true;
if shouldFilterRegions
    %[numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);
    [numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions2(template, regionByIndex, indicesByRegion, chosenFacesByRegion);
end

splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);
%SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion);


v1 = DrawFace(splicedFace, "Spliced face", false);



mergeOptions = ["MERGE_SIMPLE", "MERGE_SMOOTH_DIST", "MERGE_3"];
selectedMergeOption = 3;
shouldAverageWeights = true;

maxDistanceToSmooth = 0.25;
collageFace = MergeSimplePercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
