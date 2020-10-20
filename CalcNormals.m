function [vertNormals, faceNormals] = CalcNormals(verts, faces)

	faceNormals = CalcFaceNormals(verts, faces);
	vertNormals = CalcVertNormals(verts, faces, faceNormals);
	[vertNormals, faceNormals] = NormalizeNormals(vertNormals, faceNormals);

end

function faceNormals = CalcFaceNormals(verts, faces)

    faceNormals = zeros(size(faces, 1), 3);
    
    for i=1:size(faces, 1)
    
    	a = verts(faces(i, 1), :);
    	b = verts(faces(i, 2), :);
    	c = verts(faces(i, 3), :);
    	
    	ca = c - a;
    	ba = b - a;
    	
    	n = cross(ba, ca);
    	faceNormals(i, :) = n;
    	
    end

end

function vertNormals = CalcVertNormals(verts, faces, faceNormals)
    
    vertNormals = zeros(size(verts, 1), 3);
    
    for i=1:size(verts, 1)
    
        [rows_with_vert, ~] = find(faces == i);
    	rows_with_vert = unique(rows_with_vert);  % Make sure to filter out duplicates. Might happen if a triangle has duplicate vertices. Shouldn't happen, but you never know.
    	
    	n = sum(faceNormals(rows_with_vert, :), 1);
    	vertNormals(i, :) = n;
    	
    end

end

function [vertNormals, faceNormals] = NormalizeNormals(vertNormals, faceNormals)

    for i=1:size(faceNormals, 1)
    	faceNormals(i, :) = faceNormals(i, :) / sqrt(sum(faceNormals(i, :) .^ 2));
    end
    
    for i=1:size(vertNormals, 1)
    	vertNormals(i, :) = vertNormals(i, :) / sqrt(sum(vertNormals(i, :) .^ 2));
    end

end