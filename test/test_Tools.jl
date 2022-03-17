module TestTools
using DataFrames, CSV

using Test

include("../src/Tools.jl")
import .Tools
export runtests

function test_make_Y_bus()

    VN = 12500
    Sb = 1e6
    Yb = Sb / (VN^2)

    target_pu = [
        20-40im -20+40im 0+0im
        -20+40im 48.5714-97.1429im -28.5714+57.1429im
        0+0im -28.5714+57.1429im 28.5714-56.8429im
    ]
    target = target_pu * Yb

    data = DataFrame(CSV.File("case3_dist.csv"))

    result = Tools.make_Y_bus(data, VN)
    @testset "make_Y_bus" begin
        @testset "Y[$i, $j]" for i = 1:3, j = 1:3
            @test target[i, j] ≈ result[i, j] atol = 1e-4
        end
    end
end

function runtests()
    @testset "Tools" begin
        test_make_Y_bus()
    end
end


end


TestTools.runtests()