function senders = recalculateSenders(oldTimes, newTimes, oldSenders)
%RECALCULATESENDERS Summary of this function goes here
%   Detailed explanation goes here
    senders = zeros(3, length(newTimes));
    startPos = 1;
    for i = 1:length(newTimes)
        while true
            if startPos+1<=length(oldTimes) && oldTimes(startPos+1)<newTimes(i)
                startPos = startPos + 1;
            else
                break;
            end
        end
        if startPos == length(oldTimes)
            senders(:,i) = oldSenders(:, startPos);
        else
            t1 = oldTimes(startPos);
            t2 = oldTimes(startPos+1);
            t = newTimes(i);
            senders(:,i) = (t2-t)/(t2-t1)*oldSenders(:, startPos) + (t-t1)/(t2-t1)*oldSenders(:, startPos+1);
            % senders(:,i) = oldSenders(:, startPos);
        end
    end

end

