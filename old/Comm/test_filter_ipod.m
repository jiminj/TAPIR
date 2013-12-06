y2 = filter(Num2,Den2,x2);
y2 = abs(y2);
max_y2 = max(y2);


for i=1:length(y2)/2000-1
    result(i) = mean(y2((i-1)*2000+1:i*2000));
end

