function resultString = encodeChar( binData )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


    %%% Character Encoding %%%%%
    
    % resMat = reshape(block,8, []);
    noChar = size(binData, 2);

    resultString = char(zeros(1,noChar));

    for idx=1:noChar
         resultBin = num2str(binData(:,idx))';
         resultString(idx) = char(bin2dec(resultBin));
    end
    
end

