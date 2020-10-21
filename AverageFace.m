function mesh_out = AverageFace(mesh_in)
    
    mesh_out = clone(mesh_in);

    for vert_id = 1:size(mesh_in.Vertices, 1)
        
        [rows_with_vert, ~] = find(mesh_in.Faces == vert_id);
        
        local_vert_ids = unique(mesh_in.Faces(rows_with_vert, :));
        local_verts = mesh_in.Vertices(local_vert_ids, :);
        
        average = sum(local_verts, 1) / length(local_vert_ids);
        
        
        mesh_out.Vertices(vert_id, :) = average;        
    end
end

