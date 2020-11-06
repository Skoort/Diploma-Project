

function newFace = IntroduceSymmetry(oldFace, symmetryFactor)
    newFace = clone(oldFace);
    
    middle_verts = readmatrix("Data/template_middle_verts.txt");
    
    for i = 1:newFace.nVertices
        k = i - 1;
        j = oldFace.nVertices - k;
        
        if ismember(i, middle_verts)
            continue;  % Leave calculation of these verts after we find others.
            %{
            % Get faces containing this vertex.
            locations_ = (oldFace.Faces == i);
            [locations_, ~] = find(locations_);
            
            % Get neighboring vertices in these faces not in middle_verts.
            verts_ = unique(oldFace.Faces(locations_, :));
            verts_ = setdiff(verts_, middle_verts);

            average = sum(oldFace.Vertices(verts_, 3)) / length(verts_);
            
            % Set this vertex's Z value to that average.
            newFace.Vertices(i, 3) = average;
            %}
        else
            average = (oldFace.Vertices(i, 3) + oldFace.Vertices(j, 3)) / 2;
            
            newFace.Vertices(i, 3) = newFace.Vertices(i, 3) + (average - newFace.Vertices(i, 3)) * symmetryFactor;
        end
    end
    
    for j=1:length(middle_verts)
        vert_id = middle_verts(j);
        
        % Get faces containing this vertex.
        locations_ = (oldFace.Faces == vert_id);
        [locations_, ~] = find(locations_);

        % Get neighboring vertices in these faces not in middle_verts.
        verts_ = unique(oldFace.Faces(locations_, :));
        verts_ = setdiff(verts_, middle_verts);

        average = sum(oldFace.Vertices(verts_, 3)) / length(verts_);

        % Set this vertex's Z value to that average.
        newFace.Vertices(vert_id, 3) = average;
    end
end

