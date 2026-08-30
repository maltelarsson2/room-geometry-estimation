%There are paths that need to be updated to actual paths in the code below.

variant = 1; %Real dataset
% variant = 2; %Scannet++ dataset
% variant = 3; %Shoebox dataset

if variant == 1
    % Real experiment
    experimentNum = 1;
    datasets = [1, 1, 2, 2, 3, 3];
    intervals = [26,36; 52, 62; 30, 45; 70, 75; 32, 43; 63, 73]-10;
    % Change this to correct path, should end with a folder separator
    folder = "path\to\datasets\Recording_basement\recording_" + datasets(experimentNum) + "\"; 
    [settings, scores, r, s, walls_gt] = loadBasementData(folder, intervals(experimentNum, :), 12);
    allWalls = getWallsOuter3(r, s, scores, settings);
    
    figure()
    plot3(r(1, :), r(2, :), r(3, :), "bx")
    hold on
    plot3(s(1, :), s(2, :), s(3, :), "r.")
    plotWalls_corners2(allWalls, walls_gt)
elseif variant == 2
    scannetRoomIds = ["4e9ab3ec88", "07b8312ea9", "66ba53719a", "6183f0657d", "20207b4844", "b1d75ecd55", "b20a261fdf", "ed2216380b", "f2ec1f6a04", "f368a1f730"];
    room_number = 1;
    room_id = scannetRoomIds(room_number);
    % 
    folder = "path\to\datasets\scannetpp_rooms\recording_" + room_id + "\sim2\"; 
    
    [walls, r, s, walls_gt] = computeScannetRoom(folder, 1);
elseif variant == 3 % pyroom simulations

    room_num = 1; %Number between 1-40
    folder = "path\to\datasets\shoebox_rooms\Sim" + room_num + "\sim2\"; 
    
    allRotErrs = [];
    allTransErrs = [];
    numRooms = 40;
    rooms = cell(1,numRooms);
    numR = 6;
    cell_foundWalls = cell(1, numRooms);
    folder = folder_base+room_num+"\";
    [settings, scores, r, s, room] = loadPyroomData(folder);
    allWalls = getWallsOuter3(r, s, scores, settings);

end

%%
function [walls, r, s, walls_gt] = computeScannetRoom(folder, variant)
    [settings, scores, r, s, walls_gt] = loadPyroomData(folder, true);
    settings2 = settings;
    settings2.nbrOfPeaks = 10;
    if variant == 1
        walls = getWallsOuter3(r,s,1, scores, settings2);
    elseif variant == 2
        walls = getWallsOuter3_singleWalls(r,s,1, scores, settings2, 6);
    end
end



