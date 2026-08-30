function  plotScannetRoom(folder, room_id, r, s)
%PLOTSCANNETROOM Summary of this function goes here
%   Detailed explanation goes here

fileName = folder + room_id + "\reduced_mesh_20000.ply";

mesh = readSurfaceMesh(fileName);

indices = true(1, size(mesh.Faces, 1));
if nargin>2
    h = -Inf;
    for i = 1:size(mesh.Faces, 1)
        midPoint = mean(mesh.Vertices(mesh.Faces(i,:), :), 1);
        h = max(midPoint(3),h);
    end
    h = h-0.15;

    for i = 1:size(mesh.Faces, 1)
        midPoint = mean(mesh.Vertices(mesh.Faces(i,:), :), 1);
        % if midPoint(3) > 3.1 %|| midPoint(1)<0.5
        if midPoint(3) > h %|| midPoint(1)<0.5
            indices(i) = false;
        end
    end
end
alpha = 0;

figure()
trisurf(mesh.Faces(~indices, :), mesh.Vertices(:, 1), mesh.Vertices(:, 2), mesh.Vertices(:, 3), FaceVertexCData=mesh.VertexColors, FaceAlpha=alpha, EdgeAlpha=alpha)
hold on
trisurf(mesh.Faces(indices,:), mesh.Vertices(:, 1), mesh.Vertices(:, 2), mesh.Vertices(:, 3), FaceVertexCData=mesh.VertexColors)
hold on
if nargin>2
    plot3(s(1, :), s(2,:), s(3,:), "r.")
    plot3(r(1, :), r(2,:), r(3,:), "rx")
end

end

