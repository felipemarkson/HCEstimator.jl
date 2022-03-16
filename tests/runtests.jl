module RunTests
using Test
export runtests
function runtests()

    include("test_Tools.jl")
    include("test_DistSystem.jl")
    include("test_SimplePF.jl")
    include("test_Estimator.jl")
    include("test_HCEstimator.jl")

end
end

RunTests.runtests()
print("")