module RunTests
using Test
export runtests
function runtests()

    include("test_Tools.jl")
    include("test_DistSystem.jl")
    include("test_SimplePF.jl")
    include("test_Estimator.jl")
    include("test_HCEstimator.jl")

    @testset "example" begin
        include("../example/example.jl")
        @test true
    end

end
end

RunTests.runtests()
print("")