export @u_str, LogProfile
export logprofilefit, powerprofilefit


import Unitful: @u_str
import Makie as Mk


"""
`logprofilefit(z,u,κ)`
`logprofilefit(z,u)`

Fits the law of the wall to a velocity profile given the Von Karman coefficient `κ`:
```math
u/u⁺ = 1/κ ln(z/z₀)
```
"""
function logprofilefit(z,u, κ=0.4)
    a₁,a₂ = logfitcoefs(z, u)
    u⁺ = a₂ * κ
    z₀ = exp(-a₁/a₂)
    return z₀, u⁺
end




struct LogProfile
    z0::Float64
    uplus::Float64
    kappa::Float64
    d::Float64
    LogProfile(z0, uplus; d=0.0, kappa=0.4) = new(z0, uplus, d, kappa)
end

function LogProfile(z::AbstractVector, u::AbstractVector; d=0.0, kappa=0.4)
    z₀, u⁺ = logprofilefit(z .- d, u, kappa)
    return LogProfile(z₀, u⁺, kappa, d)
end



function interactive_logprofilefit()
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
