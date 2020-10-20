% collageFace is after merging and smoothing, splicedFace is before (only splicing).
function interpolatedFace = InterpFace(splicedFace, collageFace, interpAmount)

    interpolatedFaceVerts = splicedFace.Vertices + (collageFace.Vertices - splicedFace.Vertices) * interpAmount;
    
    interpolatedFace = clone(collageFace);  
    interpolatedFace.Vertices = interpolatedFaceVerts;

end

