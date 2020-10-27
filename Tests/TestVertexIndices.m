pathToAverage = '../Data/average.obj';
pathToTemplate = '../Data/template.obj';
pathToRegions = "../Data/template_color.ply";
pathToFaces = '../Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

face = LoadFace(pathToTemplate);

face.VertexRGB = zeros(size(face.Vertices));
for i = 1:size(face.Vertices, 1)
    face.VertexRGB(i, :) = [1, 1, 1] * i / size(face.Vertices, 1);
end
face.ColorMode = 'texture';

k = 3595;  % Middle two verts are 7160/2 and 7160/2+1.
i = 1 + k;
j = face.nVertices - k;

face.VertexRGB(i, :) = [1, 0, 0];
face.VertexRGB(j, :) = [0, 1, 0];

v1 = DrawFace(face);



face2 = clone(face);

%middle_verts = find(face2.Vertices(:, 1) == face2.Vertices(face2.nVertices/2, 1));
middle_verts = find(ismembertol(face2.Vertices(:, 1), face2.Vertices(face2.nVertices/2, 1)));
face2.VertexRGB = repmat([0, 1, 0], face2.nVertices, 1);
face2.VertexRGB(middle_verts, :) = repmat([1, 0, 0], length(middle_verts), 1);
face2.ColorMode = 'texture';


v2 = DrawFace(face2);

writematrix(middle_verts, "../Data/template_middle_verts");