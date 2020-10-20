function [angles] = CalcNormalAngles(inVerts, inFaces, inNormalsVerts)

    angles = zeros(size(inVerts, 1), 1);

    for i=1:size(inVerts, 1)

        [rows_with_vert, ~] = find(inFaces == i);
	local_vert_ids = setdiff(unique(inFaces(rows_with_vert, :)), i);

	max_angle = -Inf;
	for j=1:length(local_vert_ids)
		angle = CalcAngle(inNormalsVerts(i, :), inNormalsVerts(local_vert_ids(j), :));
		if angle > max_angle
			max_angle = angle;
		end
	end

	angles(i) = max_angle;
	
    end
    
end

