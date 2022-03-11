module TestEstimator
using Test
using JuMP, Ipopt
using DataFrames, CSV

include("../src/DistSystem.jl")
import .DistSystem

include("../src/SimplePF.jl")
import .SimplePF
export runtests


function case3_dist()
    VN = 12500
    Sb = 1e6
    Yb = Sb / (VN^2)
    Vsub = 1.0
    P_limt = 10
    Q_limit = 10
    bus_sub = 1
    nbuses = 3
    VL = 0.95
    VH = 1.05
    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [0.003, 12, 240])
    data = DataFrame(CSV.File("tests/case3_dist.csv"))

    sys = DistSystem.factory_system(data, VL, VH, sub)

    sys.dgs = [
        DistSystem.DG(3, 0.03, 0.0, [0.0026, 10.26, 210])
    ]
    sys.m_load = collect(0.5:0.1:1.1)
    sys.m_new_dg = [
        collect(0.0:0.2:1.1)
    ]





    return sys, case
end

function case33()
    VN = 12660
    Sb = 1e6
    Yb = Sb / (VN^2)
    Vsub = 1.0
    P_limt = 4
    Q_limit = 2.5
    bus_sub = 1
    nbuses = 33
    VL = 0.90
    VH = 1.05
    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [0.003, 12, 240])
    data = DataFrame(CSV.File("tests/case33.csv"))
    sys = DistSystem.factory_system(data, VL, VH, sub)
    case = Case(
        "case33",
        [1.0000, 0.9973, 0.9848, 0.9785, 0.9723, 0.9583, 0.9563, 0.9520, 0.9475, 0.9435, 0.9428, 0.9416, 0.9383, 0.9378, 0.9376, 0.9375, 0.9396, 0.9403, 0.9968, 0.9932, 0.9925, 0.9919, 0.9813, 0.9746, 0.9713, 0.9568, 0.9547, 0.9468, 0.9412, 0.9386, 0.9379, 0.9382, 0.9398],
        [0, -0.0150, -0.0934, -0.1490, -0.2104, -0.5805, -0.8319, -0.8952, -1.1107, -1.3188, -1.3396, -1.3817, -1.6797, -1.8333, -1.9543, -2.0837, -2.3423, -2.4561, -0.0258, -0.0927, -0.1121, -0.1324, -0.1242, -0.2126, -0.2561, -0.5839, -0.5881, -0.7285, -0.8235, -0.8304, -1.1211, -1.2100, -1.2906]
    )

    sys.dgs = [
        DistSystem.DG(18, 0.03, 0.0, [0.0026, 10.26, 210],
        DistSystem.DG(22, 0.03, 0.0, [0.0026, 10.26, 210],
        DistSystem.DG(25, 0.03, 0.0, [0.0026, 10.26, 210],
        DistSystem.DG(33, 0.03, 0.0, [0.0026, 10.26, 210])
    ]
    sys.m_load = collect(0.5:0.1:1.1)
    sys.m_new_dg = collect(0.0:0.2:1.1)
    return sys, case
end

function test_add_variables(sot, sys)

    return sot
end


function runtests()

    @testset "Estimator" begin
        sot = Model()
        test_add_variables(sot, sys)

    end
end

end