
export linfitcoefs, powerfitcoefs, logfitcoefs


"Fits a straight line through a set of points, `y = a₁ + a₂ * x`"
function linfitcoefs(x, y)
    
    sx = sum(x)
    sy = sum(y)

    m = length(x)

    sx2 = zero(sx.*sx)
    sy2 = zero(sy.*sy)
    sxy = zero(sx*sy)

    for i = 1:m
        sx2 += x[i]*x[i]
        sy2 += y[i]*y[i]
        sxy += x[i]*y[i]
    end

    a0 = (sx2*sy - sxy*sx) / ( m*sx2 - sx*sx )
    a1 = (m*sxy - sx*sy) / (m*sx2 - sx*sx)

    return (a0, a1)
end

"Fit the curve `y = a₁ + a₂*ln(x)`"
logfitcoefs(x, y) = linfitcoefs(log.(x), y)

"Fits a power law through a set of points: `y = a₁*x^a₂`"
function powerfitcoefs(x, y)
    a₁, a₂ = linfitcoefs(log.(x), log.(y))
    (exp(a₁), a₂)
end

