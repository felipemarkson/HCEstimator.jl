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
    VL = 0.90
    VH = 1.05
    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [0.003, 12, 240])
    data = DataFrame(CSV.File("tests/case3_dist.csv"))

    sys = DistSystem.factory_system(data, VL, VH, sub)

    sys.dgs = [
        DistSystem.DER(3, 0.02, 0.05, [0.0, 0.03], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG dispatchable
    ]
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]

    return sys, "case3_dist"
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
    sys.dgs = [
        DistSystem.DER(18, 0.02, 0.05, [0.0, 0.03], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG dispatchable
        DistSystem.DER(22, 0.02, 0.05, [0.0, 0.0], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-active dispatchable
        DistSystem.DER(33, 0.02, 0.15, [-0.01, 0.01], [-0.01, 0.01], [-1.0, 0.0, 1.0], [0.0026, 10.26, 210]), #ESS
        DistSystem.DER(25, 0.02, 0.0, [0.0, 0.0], [0.0, 0.0], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-dispatchable
    ]
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]
    return sys, "case33"
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