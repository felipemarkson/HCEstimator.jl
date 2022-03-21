module Cases
using DataFrames, CSV

include("../src/DistSystem.jl")
import .DistSystem

export case3_dist, case33, case3_dist_no_dgs

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
    data = DataFrame(CSV.File("case3_dist.csv"))

    sys = DistSystem.factory_system(data, VL, VH, sub)

    sys.dgs = [
        DistSystem.DER(3, 0.001, 0.001, 0.05, 1.0, [0.0, 0.03], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG dispatchable
        DistSystem.DER(2, 0.002, 0.002, 0.05, 1.0, [0.0, 0.03], [-0.03, 0.03], [-1.0, 0.0, 1.0], [0.0026, 10.26, 210]), #DG dispatchable
    ]
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]

    return sys, "case3_dist"
end

function case3_dist_no_dgs()
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
    data = DataFrame(CSV.File("case3_dist.csv"))

    sys = DistSystem.factory_system(data, VL, VH, sub)
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]

    return sys, "case3_dist_no_dgs"
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
    data = DataFrame(CSV.File("case33.csv"))
    sys = DistSystem.factory_system(data, VL, VH, sub)
    sys.dgs = [
        DistSystem.DER(18, 0.02, 0.02, 0.05, 0.05, [0.0, 0.03], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG dispatchable
        DistSystem.DER(22, 0.02, 0.02, 0.05, 0.05, [0.0, 0.0], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-active dispatchable
        DistSystem.DER(33, 0.02, 0.02, 0.15, 0.05, [-0.01, 0.01], [-0.01, 0.01], [-1.0, 0.0, 1.0], [0.0026, 10.26, 210]), #ESS
        DistSystem.DER(25, 0.02, 0.02, 0.0, 0.05, [0.0, 0.0], [0.0, 0.0], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-dispatchable
    ]
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]
    return sys, "case33"
end

end