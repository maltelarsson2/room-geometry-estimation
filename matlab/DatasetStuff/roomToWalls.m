function walls = roomToWalls(room)
    walls = [1, 1, 0, 0, 0, 0;
        0, 0, 1, 1, 0, 0;
        0, 0, 0, 0, 1, 1;
        0, room(1), 0, room(2), 0, room(3)];
end

