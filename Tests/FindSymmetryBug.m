
pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));


template = LoadFace(pathToTemplate);


symmetry = IntroduceSymmetry(template, 0.6);

v = viewer(symmetry);

for i = 1:symmetry.nVertices
    symmetry.VertexRGB(i, :) = [1, 1, 1];
end
symmetry.ColorMode = 'texture';

A = [];
for i = 1:symmetry.nVertices
    k = i - 1;
    j = symmetry.nVertices - k;
    
    %symmetry.VertexRGB(i, :) = [1, 0, 0];
    %symmetry.VertexRGB(j, :) = [0, 0, 1];
    
    %pause(0.01);

    if abs(symmetry.Vertices(i, 2) - symmetry.Vertices(j, 2)) > eps
        A = [A; i];
        %pause(3);
    end
    
    %symmetry.VertexRGB(i, :) = [1, 1, 1];
    %symmetry.VertexRGB(j, :) = [1, 1, 1];

    %format long;
    %disp(abs(symmetry.Vertices(i, 2) - symmetry.Vertices(j, 2)));
end


symmetry.VertexRGB(129, :) = [1, 0, 0];
symmetry.VertexRGB(130, :) = [1, 0, 0];
symmetry.VertexRGB(131, :) = [0, 0, 1];
symmetry.VertexRGB(132, :) = [0, 1, 0];
symmetry.ColorMode = 'texture';