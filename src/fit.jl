
export linfitcoefs, powerfitcoefs, logfitcoefs
export logprofilefit, powerprofilefit


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

"""
`logprofilefit(z,u,κ)`
`logprofilefit(z,u)`

Fits the law of the wall to a velocity profile given the Von Karman coefficient `κ`:
```math
u/u⁺ = 1/κ ln(z/z₀)
```
"""
function logprofilefit(z,u, κ=0.4)
    x = log.(z)
    a₁,a₂ = linfitcoefs(x, u)
    u⁺ = a₁ * κ
    z₀ = exp(-a₀/a₁)
    return z₀, u⁺
end


"""
`powerprofilefit(z,u,zref=1.0)`
`powerprofilefit(z,u)`

Fits a power law to a velocity profile:
```math
u = uref(z/zref)ᵖ
```
"""
function powerprofilefit(z, u, zref=1.0)
    uref, p = powerfitcoefs(z./zref, u)
end
