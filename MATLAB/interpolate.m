function [H_interpolated] = interpolate(H,pilot_loc,Nfft,method)
if pilot_loc(1)>1
    slope = (H(2)-H(1))/(pilot_loc(2)-pilot_loc(1));
    H = [H(1)-slope*(pilot_loc(1)-1);H]; 
    pilot_loc = pilot_loc;
    pilot_loc = [1;pilot_loc]; 
end

if pilot_loc(end) < Nfft
    slope = (H(end)-H(end-1))/(pilot_loc(end)-pilot_loc(end-1)); 
    H = [H;H(end)+slope*(Nfft-pilot_loc(end))];
    pilot_loc = [pilot_loc;Nfft];
end
if lower(method(1))=='s', H_interpolated = interp1(pilot_loc,H,[1:Nfft],'spline'); 
else H_interpolated=interp1(pilot_loc,H,[1:Nfft]);
end