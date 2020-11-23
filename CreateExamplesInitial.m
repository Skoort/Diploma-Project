% Ask Aljaz for a smaller region face with 6 regions.

pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));


template = LoadFace(pathToTemplate);

[numFaces, faces] = LoadFaces(pathToFaces);


% Has support for 7 different faces/colors.
rainbow = [255,   0,   0; ...
           255, 127,   0; ...
           255, 255,   0; ...
             0, 255,   0; ...
             0,   0, 255; ...
            46,  43,  95; ...
           139,   0, 255];

mergedFacesAmounts = [4, 5, 6, 4, 5, 6, 4, 5];       
for currExample = 1:8
    [numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);

    numMergedFaces = mergedFacesAmounts(currExample);
    [chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces);

    shouldFilterRegions = true;
    if shouldFilterRegions
        [numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);
    end

    splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);
    %SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion);
    

    v1 = DrawFace(splicedFace, "Spliced face", false);


    path = ['Examples\', num2str(currExample), '\In'];

    pathToHidden = [path, '\Hidden'];

    writematrix(chosenFaces, [pathToHidden, '\chosenFaces']);
    writematrix(regionByIndex, [pathToHidden, '\regionByIndex']);

    for i = 1:length(chosenFaces)
        filename = ['part', num2str(i), '.obj'];

        face = faces{chosenFaces(i)};
        
        face.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face.nVertices, 1);
        face.SingleColor = [0xff, 0xdb, 0xac];
        face.ColorMode = 'single';
        
        face.exportWavefront(filename, path);
        
        % Also write the 5 views Right, Front-Right, Front, Front-Left & Left
        
        v8 = DrawFace(face, "Constituent face", false);
        v8.SceneLightVisible = true;
        v8.SceneLightLinked = true;
        v8.CameraTarget = [0, 0, 0];
        v8.CameraUpVector = [0, 1, 0];

        % Right
        v8.CameraPosition = [-180, 0, 0];
        saveas(v8.Figure, [path, '\part', num2str(i), '-Right.png']);

        % Right-front
        v8.CameraPosition = [-127, 0, +127];
        saveas(v8.Figure, [path, '\part', num2str(i), '-FrontRight.png']);

        % Front
        v8.CameraPosition = [0, 0, 180];
        saveas(v8.Figure, [path, '\part', num2str(i), '-Front.png']);

        % Left-front
        v8.CameraPosition = [+127, 0, +127];
        saveas(v8.Figure, [path, '\part', num2str(i), '-FrontLeft.png']);

        % Left
        v8.CameraPosition = [+180, 0, 0];
        saveas(v8.Figure, [path, '\part', num2str(i), '-Left.png']);
    end
 
    
    for i = 1:splicedFace.nVertices
        regionColor = rainbow(regionByIndex(i), :);

        splicedFace.VertexRGB(i, :) = regionColor / 255;
    end
    splicedFace.ColorMode = 'texture';
    
    splicedFace.exportWavefront('inFace.obj', path);

    v = DrawFace(splicedFace);
    v.SceneLightVisible = true;
    v.SceneLightLinked = true;
    v.CameraTarget = [0, 0, 0];
    v.CameraUpVector = [0, 1, 0];

    
    % View right side.
    v.CameraPosition = [-180, 0, 0];
    saveas(v.Figure, [path, '\inFace-Right.png']);

    % Right-front
    v.CameraPosition = [-127, 0, +127];
    saveas(v.Figure, [path, '\inFace-FrontRight.png']);
    
    % View front.
    v.CameraPosition = [0, 0, +180];
    saveas(v.Figure, [path, '\inFace-Front.png']);

    % Left-front
    v.CameraPosition = [+127, 0, +127];
    saveas(v.Figure, [path, '\inFace-FrontLeft.png']);
    
    % View left side.
    v.CameraPosition = [+180, 0, 0];
    saveas(v.Figure, [path, '\inFace-Left.png']);
end