% Title HTML pages with number of example start face.
% Title the columns with the number of the start face followed by the
% number of the output.
% Make an html page with the outputs as columns, first column is the
% first column is the individual faces, second column is the first simple
% collage.
% Make all the faces the same human color.
% Bonus: Also, look into showing a 3D model in HTML. Worst case scenario,
% put a file link 


pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

%
averageFace = LoadFace(pathToAverage);
%
template = LoadFace(pathToTemplate);
[numFaces, faces] = LoadFaces(pathToFaces);

numModels = 6;

numExamples = 8;
for exampleId = 1:numExamples
    readPath = ['Examples/', num2str(exampleId), '/In'];
    readPathHidden = [readPath, '/Hidden'];
    
    % Read a possible modelId from the file.
    if ~exist([readPathHidden, '/map.txt'], 'file')
        models = [];
        modelId = randi([1, numModels]);
    else
        models = readmatrix([readPathHidden, '/map.txt']);
        availableModels = setdiff(1:numModels, models(:, 1));
        modelId = availableModels(randi([1, length(availableModels)]));
    end
    
    writePath = ['Examples/', num2str(exampleId), '/Out ', num2str(modelId)];
    
    if ~exist(writePath, 'dir')
        mkdir(writePath);
    end
    
    chosenFaces = readmatrix([readPathHidden, '\chosenFaces']);
    regionByIndex = readmatrix([readPathHidden, '\regionByIndex']);
    splicedFace = LoadFace([readPath, '\inFace.obj']);
    
    % We still need to calculate numRegions and indicesByRegion.
    numRegions = length(unique(regionByIndex));
    % The following code is copied from LoadRegions.GetRegions.
    indicesByRegion = cell(numRegions, 1);
    chosenFacesByRegion = zeros(numRegions, 1);
    
    % Iterate over the vertices and add each vertex to its corresponding
    % region.
    for j = 1:length(regionByIndex)
        region = regionByIndex(j);
        indicesByRegion{region} = [indicesByRegion{region}; j];
        chosenFacesByRegion(region) = region;
    end
    
    splicedFace.VertexRGB(indicesByRegion{1}, :) = repmat([0, 1, 0], length(indicesByRegion{1}), 1);
    splicedFace.ColorMode = 'texture';
    
    %v = DrawFace(splicedFace, "Spliced face", false);
    
    
    % Start messing with the face.
    
    % PARAMS %%%%%%%%%%%%%%%%%%2,0.75,1,1,0.35,0,0,0.95
    selectedMergeOption = 2;
    maxDistanceToSmooth = 3;
    shouldAverageWeights = true;
    numFits = 1;  % The number of Meshmonk fits.
    symmetryFactor = 0.80;  % Used to introduce symmetry along vertical axes.
    shouldAverageFaceAfterSymmetry = false;
    shouldFitMeshAgainAfterSymmetry = false;
    interpAmount = 1;
    % PARAMS %%%%%%%%%%%%%%%%%%

    if selectedMergeOption == 1
        collageFace = MergeSimple(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    elseif selectedMergeOption == 2
        collageFace = MergeSimplePercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    elseif selectedMergeOption == 3
        collageFace = MergeSmooth(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights);  % <- Done
    elseif selectedMergeOption == 4
        collageFace = MergeSmoothPercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    elseif selectedMergeOption == 5
        collageFace = Merge3(splicedFace, shouldAverageWeights);  % <- To implement.
    else
        warning("Incorrect merge option selected!");
    end


    %v3 = DrawFace(collageFace, "Merge before fit");


    for i=1:numFits
        collageFace = MeshFit2(collageFace);  % <- Done
    end


    %v4 = DrawFace(collageFace, "Merge after fit");

    
    
    collageFace2 = IntroduceSymmetry(collageFace, symmetryFactor);


    %v5 = DrawFace(collageFace2, "After introducing symmetry.");
    %}


    if shouldAverageFaceAfterSymmetry
        smoothSymmetryFace = AverageFace(collageFace2);

        %v6 = DrawFace(smoothSymmetryFace, "Symmetry face after average", false);
    else
        smoothSymmetryFace = collageFace2;
    end


    if shouldFitMeshAgainAfterSymmetry
        smoothSymmetryFace2 = MeshFit2(smoothSymmetryFace);  % <- Done

        %v7 = DrawFace(smoothSymmetryFace2, "Symmetry face after average and refitting.", false);
    else
        smoothSymmetryFace2 = smoothSymmetryFace;
    end


    interpolatedFace = InterpFace(splicedFace, smoothSymmetryFace2, interpAmount);  % <- Done
    interpolatedFace.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, interpolatedFace.nVertices, 1);
    interpolatedFace.SingleColor = [0xff, 0xdb, 0xac];
    interpolatedFace.ColorMode = 'single';

    v8 = DrawFace(interpolatedFace, "Interpolated face", false);

    
    v8.SceneLightVisible = true;
    v8.SceneLightLinked = true;
    v8.CameraTarget = [0, 0, 0];
    v8.CameraUpVector = [0, 1, 0];
    
    % Right
    v8.CameraPosition = [-180, 0, 0];
    saveas(v8.Figure, [writePath, '\outFace-Right.png']);
    
    % Right-front
    v8.CameraPosition = [-127, 0, +127];
    saveas(v8.Figure, [writePath, '\outFace-FrontRight.png']);
    
    % Front
    v8.CameraPosition = [0, 0, 180];
    saveas(v8.Figure, [writePath, '\outFace-Front.png']);
    
    % Left-front
    v8.CameraPosition = [+127, 0, +127];
    saveas(v8.Figure, [writePath, '\outFace-FrontLeft.png']);
    
    % Left
    v8.CameraPosition = [+180, 0, 0];
    saveas(v8.Figure, [writePath, '\outFace-Left.png']);
    
    interpolatedFace.exportWavefront('outFace.obj', writePath);
    
    models = [models; modelId, selectedMergeOption, maxDistanceToSmooth, shouldAverageWeights ...
        numFits, symmetryFactor, shouldAverageFaceAfterSymmetry, shouldFitMeshAgainAfterSymmetry, interpAmount];

    writematrix(models, [readPathHidden, '/map.txt']);
    % Stop messing with the face.
end


