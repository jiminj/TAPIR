y2 = filter(Num2,Den2,x2);
y2 = abs(y2);
max_y2 = max(y2);

start_point = 0;

for i=1:length(y2)
    if start_point == 0
        if y2(i) > max_y2*2/3
            start_point = i;
        end
    end
end


rcv_msg = 0;
result = 0;

max_var = 0;
i_var = 1;

var_array = zeros(2000000,1);

for j=1:50:44100
    j
    start_point = j;
for i=1:(length(x2)-start_point)/2000-1
    result(i) = mean(y2((i-1)*2000+start_point:i*2000+start_point-1));
end
var_array((j+49)/50) = var(result);
if max_var < var(result)
    max_var = var(result);
    i_var = j;
end
end

start_point = i_var;
for i=1:(length(x2)-start_point)/2000-1
    result(i) = mean(y2((i-1)*2000+start_point:i*2000+start_point-1));
end

max_result = max(result);

for i=1:length(result)
    if result(i) > max_result*1/3
        rcv_msg(i) = 1;
    else
        rcv_msg(i) = 0;
    end
end