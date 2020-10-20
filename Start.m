% Ask Aljaz for a smaller region face with 6 regions.

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

shouldFilterRegions = true;
if shouldFilterRegions
    [numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);
end

splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);
%SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion);


v = DrawFace(splicedFace, "Spliced face", false);


mergeOptions = ["MERGE_SIMPLE", "MERGE_SMOOTH_DIST", "MERGE_3"];
selectedMergeOption = 2;
shouldAverageWeights = true;

if selectedMergeOption == 1
    collageFace = MergeSimple(splicedFace, shouldAverageWeights);  % <- To implement.
elseif selectedMergeOption == 2
    collageFace = MergeSmooth(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights);  % <- Done
elseif selectedMergeOption == 3
    collageFace = Merge3(splicedFace, shouldAverageWeights);  % <- To implement.
else
    warning("Incorrect merge option selected!");
end


DrawFace(collageFace, "Merge before fit");


numFits = 1;
for i=1:numFits
    collageFace = MeshFit2(collageFace);  % <- Done
end


DrawFace(collageFace, "Merge after fit");


interpAmount = 0.8;

interpolatedFace = InterpFace(splicedFace, collageFace, interpAmount);  % <- Done


DrawFace(interpolatedFace, "Interpolated face", false);


factorOfAverage = 0.3;
finalFace = interpolatedFace;
numBins = 11;
upperAngleLimit = 90;
HistogramStuff(averageFace, factorOfAverage, faces, chosenFaces, finalFace, numBins, upperAngleLimit);