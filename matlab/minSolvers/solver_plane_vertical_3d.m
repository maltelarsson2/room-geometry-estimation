function sols = solver_plane_vertical_3d(r, s, d)
    % Action =  x*z
    % Quotient ring basis (V) = 1,x*z,y*z,z^2,
    % Available monomials (RR*V) = x^2*z^2,x*y*z^2,x*z^3,1,x*z,y*z,z^2,

    
    data = [r; s; d'.^2];
    % data = [r(:); s(:); d.^2];

    data = data(:); % Maybe?

    [C0, C1] = setup_elimination_template(data);
    C1 = C0 \ C1;
    RR = [-C1(end-2:end, :); eye(size(C1, 2))];
    AM_ind = [5, 1, 2, 3];
    AM = RR(AM_ind, :);
    % D, V = eigen(AM)
    % V = V ./ V(1,:)'
	% sols = zeros(ComplexF64, 4, 4)
    % sols(4,:) = sqrt.(V(4,:))
    % sols(1,:) = D ./ sols(3,:)
    % sols(2,:) = V(3,:) ./ sols(3,:)

   	[V, ~] = eig(AM);
    V = V ./ sqrt(sum(V([2, 3], :).^ 2, 1));
	sols = zeros(4, 4);
	sols(1,:) = V(2,:);
	sols(2,:) = V(3,:);
	sols(4,:) = V(4,:);
    sols = realSols(sols);
end

function realSols = realSols(sols)
    realSols = [];
    for i = 1:size(sols,2)
        sol = sols(:, i);
        if sum(imag(sol).^2)/sum(abs(sol).^2) < 1e-7
            realSols = [realSols, real(sol)];
        end
    end
end

function coeffs = compute_coeffs(data)
	coeffs = zeros(1, 15);
    coeffs(1) = 4 * data(1) * data(4);
    coeffs(2) = 4 * data(2) * data(4) + 4 * data(1) * data(5);
    coeffs(3) = 4 * data(2) * data(5);
    coeffs(4) = -4 * data(1) - 4 * data(4);
    coeffs(5) = -4 * data(2) - 4 * data(5);
    coeffs(6) = 4;
    coeffs(7) = data(1)^2 + data(2)^2 + data(3)^2 - 2 * data(1) * data(4) + data(4)^2 - 2 * data(2) * data(5) + data(5)^2 - 2 * data(3) * data(6) + data(6)^2 - data(7);
    coeffs(8) = 4 * data(8) * data(11);
    coeffs(9) = 4 * data(9) * data(11) + 4 * data(8) * data(12);
    coeffs(10) = 4 * data(9) * data(12);
    coeffs(11) = -4 * data(8) - 4 * data(11);
    coeffs(12) = -4 * data(9) - 4 * data(12);
    coeffs(13) = data(8)^2 + data(9)^2 + data(10)^2 - 2 * data(8) * data(11) + data(11)^2 - 2 * data(9) * data(12) + data(12)^2 - 2 * data(10) * data(13) + data(13)^2 - data(14);
    coeffs(14) = 1;
    coeffs(15) = -1;
end

function [C0, C1] = setup_elimination_template(data)
    coeffs = compute_coeffs(data);
    coeffs0_ind = [1, 8, 2, 1, 8, 9, 14, 3, 2, 9, 10, 3, 10, 14, 1, 8, 14, 4, 11, 2, 8, 1, 9, 14, 5, 4, 11, 12, 3, 9, 2, 10, 14, 5, 12, 10, 3, 14, 6, 6, 12, 5, 10, 3, 14, 6, 6, 12, 5, 6, 6, 8, 14, 1, 7, 13, 9, 2, 7, 13, 10, 14, 3, 15, 4, 11, 8, 1, 14, 6, 6, 5, 11, 4, 12, 9, 2, 6, 6, 11, 4];
    coeffs1_ind = [13, 15, 7, 7, 13, 11, 4, 15, 13, 7, 12, 5, 15, 13, 7, 15, 6, 6];
    C0_ind = [1, 4, 18, 19, 20, 21, 33, 35, 36, 37, 38, 53, 54, 67, 73, 76, 85, 86, 89, 90, 91, 92, 93, 100, 103, 104, 105, 106, 107, 108, 109, 110, 119, 121, 122, 125, 126, 134, 138, 139, 142, 143, 145, 146, 147, 159, 160, 162, 163, 179, 180, 199, 200, 201, 205, 208, 216, 218, 223, 224, 233, 234, 235, 237, 243, 246, 247, 248, 249, 256, 259, 260, 261, 262, 263, 264, 265, 277, 280, 281, 282];
    C1_ind = [12, 13, 14, 22, 25, 29, 31, 34, 40, 41, 46, 48, 49, 60, 61, 62, 63, 65];
    C0 = zeros(17, 17);
    C1 = zeros(17, 4);
    C0(C0_ind) = coeffs(coeffs0_ind);
    C1(C1_ind) = coeffs(coeffs1_ind);
end
