function inRange=SetToRange(val,range)

lower=range(1);
upper=range(2);

if ((val<lower)||(val>upper))
    if abs(val-lower)>abs(val-upper)
        inRange=upper;
    else
        inRange=lower;
    end
else
    inRange=val;
end
