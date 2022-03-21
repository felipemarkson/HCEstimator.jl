module HCEstimator

include("Tools.jl")
using .Tools
include("DistSystem.jl")
using .DistSystem
include("Estimator.jl")
using .Estimator

export DistSystem, build_model, Tools
import JuMP


function build_model(model::JuMP.Model, sys, obj=true)
    if isempty(sys.dgs)
        push!(sys.dgs, DistSystem.null_der(sys.buses))
    end
    model = nl_pf(model, sys)
    if obj
        model = add_objective(model, sys)
    end
    return model
end

end