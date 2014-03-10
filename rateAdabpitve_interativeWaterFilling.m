function [H_op, P_op] = rateAdabpitve_interativeWaterFilling(H,P,sigma)
M = size(H,1);
N = size(H,2);

% calculate K_n
if size(sigma) == [M,M]
    K_n = sigma;
elseif size(sigma,1) == M
    K_n = diag(sigma);
else
    K_n = eye(M)*sigma;
end

v = trace(P)/N; % Power Constraint
P_op = P;

% get decoding Order
[~,~,order] = MIMO_Receiver(H,P,sigma,'MMSE_VBLAST');
for j=1:10 % number of iterations till it converges
    for k=N:-1:1  % i should be orderd by the inverse decoding order of V_BLAST
        
        i=order(k);
        % Calculate the Channel with respect to inter-channel interference
        % and Noise
        R_n = H(:,[1:i-1 i+1:end]) * P_op([1:i-1 i+1:end],[1:i-1 i+1:end]) * H(:,[1:i-1 i+1:end])' + K_n; % Interference and Noise
        H_eq = R_n^(-1/2)*H(:,i);
        
        [~,S,V]=svd(H_eq,0);
        epsilon=v-S.^(-1);
        P_op(i) = V'*epsilon*V;
    end
end

H_op = H;

end