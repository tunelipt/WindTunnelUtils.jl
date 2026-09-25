export @u_str, LogProfile
export logprofilefit, powerprofilefit
export PowerProfile, LogProfile, i_logprofile, i_powerprofile


import Unitful: @u_str
using Makie

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
end
Base.broadcastable(p::LogProfile) = Ref(p)

function LogProfile(z::AbstractVector, u::AbstractVector; d=0.0, kappa=0.4)
    z₀, u⁺ = logprofilefit(z .- d, u, kappa)
    return LogProfile(z₀, u⁺, kappa, d)
end

(p::LogProfile)(z) = p.uplus / p.kappa * log( (z-p.d) / p.z0 )


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


struct PowerProfile
    zref::Float64
    uref::Float64
    p::Float64
    d::Float64
end
Base.broadcastable(p::PowerProfile) = Ref(p)
(p::PowerProfile)(z) = p.uref * ( (z-p.d) / p.zref)^p.p

function PowerProfile(z, u; zref=10.0, d=0.0)
    uref, p = powerprofilefit(z,u,zref)
    PowerProfile(zref, uref, p, d)
end




struct InteractiveProfile{ZVec<:AbstractVector, UVec<:AbstractVector,
                          IVec<:AbstractVector,Profile}
    z::ZVec
    u::UVec
    idx::IVec
    p::Profile
end
Base.broadcastable(p::InteractiveProfile) = Ref(p)

(p::InteractiveProfile)(z) = p.p(z)

function interactive_profile(fig, z, u, make_profile, labelfun;
                             uscale=identity, zscale=log10, heights=[], snap=true)
    pts = Observable(Point2.(u,z))

    ax = Axis(fig[1,1], xlabel="Velocidade (m/s)", ylabel="Altura (m)", 
	      xscale=uscale, yscale=zscale)
    
    sl = IntervalSlider(fig[1,2], range=eachindex(z), horizontal=false, 
			startvalues=(firstindex(z), lastindex(z)), snap=snap)

    cc = lift(sl.interval) do idx
	cc = fill(:blue, length(z))
	cc[idx[1]:idx[2]] .= :red
	cc
    end

    scatter!(ax, pts, color=cc)

    # Fit the data:
    
    fit = lift(sl.interval) do idx_slider
        idx = idx_slider[1]:idx_slider[2]
        z1 = z[idx]
        u1 = u[idx]
        profile = make_profile(z1, u1)
        InteractiveProfile(z, u, idx, profile)
    end
    
    fitpts = lift(fit) do f
        u1 = f.(z)
        Point2.(u1, z)
    end
    lines!(ax, fitpts)
    
    if length(heights)>0
	hlines!(ax, heights, linestyle=:dot)
    end

    if !isnothing(labelfun)
        
        txt = lift(fit) do f
            labelfun(f.p)
        end
        text!(ax, 0.05, 0.95, text=txt, align=(:left,:top), space=:relative)
    end


    return fit
end

function i_logprofile(fig, z, u; kappa=0.4, d=0.0, heights=[], snap=true,
                      zscale=log10, uscale=identity)
    interactive_profile(fig, z, u, (z,u)->LogProfile(z,u; kappa=kappa, d=d),
                        p->"z₀ = $(round(Int, 1000*p.z0)) mm";
                        uscale=uscale, zscale=zscale, heights=heights,
                        snap=snap)
end

function i_powerprofile(fig, z, u; zref=10.0, d=0.0, heights=[], snap=true,
                        zscale=log10, uscale=log10)
    
    interactive_profile(fig, z, u, (z,u)->PowerProfile(z,u; zref=zref, d=d),
                        p->"p = $(round(p.p, digits=2))";
                        uscale=uscale, zscale=uscale, snap=snap, heights=heights)
end


function i_fpprofile(fig, z, u; zref=10.0, d=0.0, snap=true,
                        zscale=log10, uscale=log10)
    
    interactive_profile(fig, z, u, (z,u)->PowerProfile(z,u; zref=1.0, d=d),
                        p->"fₚ = $(round(p(zref), digits=3))";
                        uscale=uscale, zscale=uscale, snap=snap, heights=[zref])
end



    
