function v = DrawFace(face, name, shouldClone, pos, target, up)

    if nargin < 2
        name = "Default face viewer";
    end
    if nargin < 3
        shouldClone = true;
    end
    if nargin < 5
        warning("Some DrawFace params not supplied. Using default");
        pos = [1.1702e+03 160.4910 964.0258];
        target = [-0.5501 7.3659 18.5728];
        up = [-0.0678 0.9947 -0.0772];
    end

    if shouldClone
        face = clone(face);
    end
    
    v = viewer(face); 
    v.SceneLightVisible = true;
    v.SceneLightLinked = true;
    v.CameraPosition = pos;
    v.CameraTarget = target;
    v.CameraUpVector = up;
    v.Tag = name;

end

