function r=randBetween(a,b,m,n)
% randBetween.m - returns a m x n array of random numbers between a and b.
    
    
    r=floor((b-a+1)*rand(m,n)+a);
end