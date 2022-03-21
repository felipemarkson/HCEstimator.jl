module TestHCEstimator
using Test
using JuMP, Ipopt
using DataFrames, CSV

include("../src/HCEstimator.jl")
using .HCEstimator
include("../src/Estimator.jl")
using .Estimator

include("cases_no_v.jl")
using .Cases


function runtests()

    @testset "HCEstimator" begin
        for case in [case3_dist, case33, case3_dist_no_dgs]
            sys, name = case()
            @testset "$name" begin
                other = nl_pf(Model(), sys)
                other_w_obj = add_objective(other, sys)

                sot = build_model(Model(), sys)
                @test sprint(print, sot) == sprint(print, other_w_obj)

                other_sot = build_model(Model(), sys, false)
                @test sprint(print, sot) == sprint(print, other)
            end

        end
    end
end

end
TestHCEstimator.runtests()