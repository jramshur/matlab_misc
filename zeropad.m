function output=zeropad(s)
% zeropad: pads end of array with zeros up to next power of 2
    output=padarray(s,2^(nextpow2(s)+1)-length(s),0,'post');
end