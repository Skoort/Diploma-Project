pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));


numModels = 6;

numExamples = 8;

faceCounts = [4, 5, 6, 4, 5, 6, 4, 5];

rainbow = [255,   0,   0; ...
           255, 127,   0; ...
           255, 255,   0; ...
             0, 255,   0; ...
             0,   0, 255; ...
            46,  43,  95; ...
           139,   0, 255];
       
for exampleId = 1:numExamples
    readPath = ['Examples/', num2str(exampleId), '/In'];
    readPathHidden = [readPath, '/Hidden'];
    
    % Read initial faces.
    for faceId = 1:faceCounts(exampleId)
        name = ['\part', num2str(faceId), '.obj'];
        % Read obj.
        face = LoadFace([readPath, name]);
        
        % Change colors.
        face.VertexRGB = repmat(rainbow(faceId, :) / 255, face.nVertices, 1);
        face.SingleColor = rainbow(faceId, :) / 255;
        face.ColorMode = 'single';
        
        % Change light and take pictures.
        v8 = DrawFace(face, "Interpolated face", false);
        v8.SceneLightVisible = true;
        v8.SceneLightLinked = true;
        v8.CameraTarget = [0, 0, 0];
        v8.CameraUpVector = [0, 1, 0];
        v8.SceneLightPosition = [0, 0, 180];

        % Right
        v8.CameraPosition = [-180, 0, 0];
        saveas(v8.Figure, [readPath, '\part', num2str(faceId), '-Right.png']);

        % Right-front
        v8.CameraPosition = [-127, 0, +127];
        saveas(v8.Figure, [readPath, '\part', num2str(faceId), '-FrontRight.png']);

        % Front
        v8.CameraPosition = [0, 0, 180];
        saveas(v8.Figure, [readPath, '\part', num2str(faceId), '-Front.png']);

        % Left-front
        v8.CameraPosition = [+127, 0, +127];
        saveas(v8.Figure, [readPath, '\part', num2str(faceId), '-FrontLeft.png']);

        % Left
        v8.CameraPosition = [+180, 0, 0];
        saveas(v8.Figure, [readPath, '\part', num2str(faceId), '-Left.png']);
    end
    
    % Read spliced.
    name = '\inFace.obj';
    % Read obj.
    face = LoadFace([readPath, name]);
    
    regionByIndex = readmatrix([readPathHidden, '\regionByIndex']);
    

    for j = 1:length(regionByIndex)
        face.VertexRGB(j, :) = rainbow(regionByIndex(j), :) / 255;
    end
    
    face.ColorMode = 'texture';

    % Change light and take pictures.
    v8 = DrawFace(face, "Interpolated face", false);
    v8.SceneLightVisible = true;
    v8.SceneLightLinked = true;
    v8.CameraTarget = [0, 0, 0];
    v8.CameraUpVector = [0, 1, 0];
    v8.SceneLightPosition = [0, 0, 180];

    % Right
    v8.CameraPosition = [-180, 0, 0];
    saveas(v8.Figure, [readPath, '\inFace-Right.png']);

    % Right-front
    v8.CameraPosition = [-127, 0, +127];
    saveas(v8.Figure, [readPath, '\inFace-FrontRight.png']);

    % Front
    v8.CameraPosition = [0, 0, 180];
    saveas(v8.Figure, [readPath, '\inFace-Front.png']);

    % Left-front
    v8.CameraPosition = [+127, 0, +127];
    saveas(v8.Figure, [readPath, '\inFace-FrontLeft.png']);

    % Left
    v8.CameraPosition = [+180, 0, 0];
    saveas(v8.Figure, [readPath, '\inFace-Left.png']);
    
    % Read model outputs.
    for modelId = 1:numModels
        writePath = ['Examples/', num2str(exampleId), '/Out ', num2str(modelId)];
        
        name = '\outFace.obj';
        % Read obj.
        face = LoadFace([writePath, name]);
        
        % Change colors.
        face.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face.nVertices, 1);
        face.SingleColor = [0xff, 0xdb, 0xac];  % Why not dividing by 255 here?
        face.ColorMode = 'single';

        % Change light and take pictures.
        v8 = DrawFace(face, "Interpolated face", false);
        v8.SceneLightVisible = true;
        v8.SceneLightLinked = true;
        v8.CameraTarget = [0, 0, 0];
        v8.CameraUpVector = [0, 1, 0];
        v8.SceneLightPosition = [0, 0, 180];

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
    end
end


