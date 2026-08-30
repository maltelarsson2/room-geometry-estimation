function d_nlos = shift_dnlos(d_nlos, shift_matrix)
    for i = 1:size(d_nlos, 1)
        for j = 1:size(d_nlos, 2)
            d_nlos{i,j} = d_nlos{i, j} + shift_matrix(i,j);
        end
    end
end
