module TestDistSystem
using Test
using DataFrames, CSV

include("../src/DistSystem.jl")
include("case33_ybus.jl")
import .DistSystem
export runtests

function test_null_der()
    buses = ["a", "2"]
    null_der = DistSystem.null_der(buses)

    @test null_der isa DistSystem.DER
    @test null_der.bus == buses[2]
    @test null_der.S_limit == 0.0
    @test null_der.energy == 0.0
    @test null_der.alpha == 0.0
    @test null_der.beta == 1.0
    @test null_der.P_limit == [0.0, 0.0]
    @test null_der.Q_limit == [0.0, 0.0]
    @test null_der.scenario == [0.0]
    @test null_der.Cost == [0.0, 0.0, 0.0]

end
function test_factory_system_case3_dist()
    VN = 12500
    Sb = 1e6
    Yb = Sb / (VN^2)
    Vsub = 1.0
    P_limt = 3
    Q_limit = 3
    bus_sub = 1
    nbuses = 3

    VL = 0.95
    VH = 1.05

    data = DataFrame(CSV.File("case3_dist.csv"))

    Y_target = [
        20-40im -20+40im 0+0im
        -20+40im 48.5714-97.1429im -28.5714+57.1429im
        0+0im -28.5714+57.1429im 28.5714-56.8429im
    ]

    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [1.0, 2, 3])
    Bsh = (-(data.Bshunt_MVAr * 1e6) ./ (sub.nominal_voltage^2)) / Yb

    amp = collect(skipmissing(data.Amp_pu))

    sys = DistSystem.factory_system(data, VL, VH, sub)

    @testset "case3_dist" begin

        for i = 1:nbuses, j = 1:nbuses
            @test Y_target[i, j] ≈ sys.Y[i, j] atol = 1e-4
        end
        @test nbuses == sys.nbuses
        @test VL == sys.VL
        @test VH == sys.VH
        @test collect(skipmissing(data.P_MW)) == sys.PL
        @test collect(skipmissing(data.Q_MVAr)) == sys.QL
        @test [1.0] == sys.m_load
        @test [[0.0]] == sys.m_new_dg
        @test sub == sys.substation
        @test amp = sys.amp
        @test collect(skipmissing(data.Bus)) == sys.buses
        @test -collect(skipmissing(data.Bshunt_MVAr)) == sys.Bsh

        # TODO: Find a way to test it better.
        null_der = DistSystem.null_der(sys.buses)
        fields = fieldnames(DistSystem.DER)
        for field in fields
            @test getfield(null_der, field) == getfield(sys.dgs[1], field)
        end
        @test_throws BoundsError sys.dgs[2]
    end
end

function test_factory_system_case33_dist()
    VN = 12660
    Sb = 1e6
    Yb = Sb / (VN^2)
    Vsub = 1.0
    P_limt = 3
    Q_limit = 3
    bus_sub = 1
    nbuses = 33

    VL = 0.95
    VH = 1.05

    data = DataFrame(CSV.File("case33.csv"))

    Y_target = get_ybus()

    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [1.0, 2, 3])
    Bsh = (-(data.Bshunt_MVAr * 1e6) ./ (sub.nominal_voltage^2)) / Yb

    amp = collect(skipmissing(data.Amp_pu))

    sys = DistSystem.factory_system(data, VL, VH, sub)

    @testset "case33" begin

        for i = 1:nbuses, j = 1:nbuses
            @test Y_target[i, j] ≈ sys.Y[i, j] atol = 1e-3
        end
        @test nbuses == sys.nbuses
        @test VL == sys.VL
        @test VH == sys.VH
        @test collect(skipmissing(data.P_MW)) == sys.PL
        @test collect(skipmissing(data.Q_MVAr)) == sys.QL
        @test [1.0] == sys.m_load
        @test [[0.0]] == sys.m_new_dg
        @test 0.0 == sys.time_curr
        @test sub == sys.substation
        @test amp = sys.amp
        @test collect(skipmissing(data.Bus)) == sys.buses
        @test -collect(skipmissing(data.Bshunt_MVAr)) == sys.Bsh

        # TODO: Find a way to test it better.
        null_der = DistSystem.null_der(sys.buses)
        fields = fieldnames(DistSystem.DER)
        for field in fields
            @test getfield(null_der, field) == getfield(sys.dgs[1], field)
        end
        @test_throws BoundsError sys.dgs[2]
    end
end

function runtests()
    @testset "DistSystem" begin
        test_null_der()
        test_factory_system_case3_dist()
        test_factory_system_case33_dist()
    end
end


end


TestDistSystem.runtests()