module TestHCEstimator
using Test
export runtests
function runtests()

    @testset "HCEstimator" verbose=true begin

        include("test_Tools.jl")
        include("test_DistSystem.jl")
        include("test_SimplePF.jl")
        include("test_Estimator.jl")

    end
end
end

TestHCEstimator.runtests()
print("")