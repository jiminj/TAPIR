
block = -1+2*round(rand(16, 1))
block(block<0) = 0;

msg = 't';
binData = dec2bin(msg, 8)' - 48;

if (mod(size(binData,2),2) == 1)
    binData = [binData, zeros(8,1)];
end
binData

% 
% bunchedBinData = zeros(16,size(binData,2)/2);
% for idx = 1: size(bunchedBinData,2)
%     bunchedBinData(: ,idx) = [binData(:,idx); binData(:,idx+1)];
% end
% 
% newBlk = zeros(size(bunchedBinData,1)/2, size(bunchedBinData,2));
% idx = 1 : size(newBlk,2);
% k = 1:size(newBlk,1);
%         newBlk(k,idx) = bunchedBinData(k*2-1,idx)*2 + bunchedBinData(k*2,idx);
    
bunchedBlk = zeros(16,size(binData,2)/2);
k = 1 : size(bunchedBlk,2);
bunchedBlk(: ,k) = [binData(:,k); binData(:,k+1)];
    
reducedBlk = zeros(size(bunchedBlk,1)/2, size(bunchedBlk,2));
m = 1 : size(reducedBlk,1);
reducedBlk(m,k) = bunchedBlk(m*2-1,k)*2 + bunchedBlk(m*2,k);
            
        
        
newBlk = reducedBlk
modBlk = qammod(newBlk,4)

figure();
subplot(2,1,1);
stem(real(modBlk)); hold on;
stem(imag(modBlk),'g');
subplot(2,1,2);
scatter(real(modBlk(:)),imag(modBlk(:)), '*'); grid on;