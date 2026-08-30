%filename should contain path to layouts_train.json, for ground truth
%positions. Can be downloaded from https://github.com/ghanning/PixCuboid/blob/main/pixloc/pixlib/datasets/scannetpp/layouts_train.json
function [R, t, s] = getGtCuboid(room_id, filename)
    valid_room_id = matlab.lang.makeValidName(room_id);
    S = readstruct(filename);
    roomData = S.(valid_room_id);
    R = zeros(3);
    R_temp = roomData.R;
    % for i = 1:3
    %     R(i, :) = R_temp{i};
    % end
    for i = 1:3
        R(:, i) = R_temp{i};
    end

    t = roomData.t;
    s = roomData.s;

end