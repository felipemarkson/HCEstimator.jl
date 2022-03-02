module HCEstimator

export DistSystem, build_model

using JuMP

include("Tools.jl")
using .Tools
include("DistSystem.jl")
using .DistSystem
include("PowerFlow.jl")
using .PowerFlow


function build_model(model, sys)
    model = factory_model(model, sys)
    return model
end

end