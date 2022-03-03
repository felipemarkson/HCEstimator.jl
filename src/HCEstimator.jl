module HCEstimator

export DistSystem, build_model, Get

using JuMP

include("Tools.jl")
using .Tools
include("DistSystem.jl")
using .DistSystem
include("PowerFlow.jl")
using .PowerFlow


function build_model(model, sys, hc=true)
    if (sys.m_new_dg == [[0.0]]) | (length(sys.m_new_dg) < 1)
        if !hc
            model = factory_model(model, sys, false) # Min. Costs            
        else
            error("Needs DGs multipliers for HC")
        end
    else
        if hc
            model = factory_model(model, sys, true)
        else
            error("No DGs multipliers for Min. Costs")
        end
    end
    return model
end

end