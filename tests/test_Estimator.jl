module TestEstimator
using Test
using JuMP, Ipopt
using DataFrames, CSV

include("../src/DistSystem.jl")
import .DistSystem

include("../src/SimplePF.jl")
import .SimplePF
export runtests

include("../src/Estimator.jl")
import .Estimator

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

function test_build_sets(sys)
    Ω = sys.buses
    bΩ = filter(bus -> bus != sys.substation.bus, Ω)
    L = collect(1:length(sys.m_load))
    D = collect(1:length(sys.dgs))
    K = collect(1:reduce(*, length(der.scenario) for der in sys.dgs))
    S = collect(1:length(sys.m_new_dg))

    (Ωr, bΩr, Lr, Kr, Dr, Sr) = Estimator.build_sets(sys)
    @test Ω == Ωr
    @test bΩ == bΩr
    @test L == Lr
    @test K == Kr
    @test D == Dr
    @test S == Sr
end

function test_add_variables(sot, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    n_L = length(L)
    n_D = length(D)
    n_K = length(K)
    n_S = length(S)
    n_bus = length(Ω)

    n_volts = 2 * n_bus * n_L * n_K * n_S
    n_p_der = n_D*n_L * n_K * n_S
    n_q_der = n_D*n_L * n_K * n_S
    n_p_hc = 1

    n_var = n_volts + n_p_der + n_q_der + n_p_hc

    sot = Estimator.add_variables(sot, sys)
    @testset "add_variables" begin
        @test sot isa Model
        V = sot[:V]
        pᴰᴱᴿ = sot[:pᴰᴱᴿ]
        qᴰᴱᴿ = sot[:qᴰᴱᴿ]
        pᴴᶜ = sot[:pᴴᶜ]
        @test num_variables(sot) == n_var

        @testset "V[$b, $l, $k, $s]" for b = Ω, l = L, d = D, k = K[d], s = S
            @testset "Start values" begin
                @test start_value(V[:Re, b, l, k, s]) == 1.0
                @test start_value(V[:Im, b, l, k, s]) == 0.0
            end

            @testset "Lower bound" begin
                @test lower_bound(V[:Re, b, l, k, s]) == -sys.VH
                @test lower_bound(V[:Im, b, l, k, s]) == -sys.VH
            end
            @testset "Upper bound" begin
                @test upper_bound(V[:Re, b, l, k, s]) == sys.VH
                @test upper_bound(V[:Im, b, l, k, s]) == sys.VH
            end
        end

        @testset "pᴰᴱᴿ[$d, $l, $k, $s]" for d = D, l = L, k = K, s = S
            @testset "Start values" begin
                @test start_value(pᴰᴱᴿ[d, l, k, s]) == 0.0
            end
            @testset "Bounds" begin
                @test lower_bound(pᴰᴱᴿ[d, l, k, s]) == sys.dgs[d].P_limit[1]
                @test upper_bound(pᴰᴱᴿ[d, l, k, s]) == sys.dgs[d].P_limit[2]
            end
        end

        @testset "qᴰᴱᴿ[$d, $l, $k, $s]" for d = D, l = L, k = K[d], s = S
            @testset "Start values" begin
                @test start_value(qᴰᴱᴿ[d, l, k, s]) == 0.0
            end
            @testset "Bounds" begin
                @test lower_bound(qᴰᴱᴿ[d, l, k, s]) == sys.dgs[d].Q_limit[1]
                @test upper_bound(qᴰᴱᴿ[d, l, k, s]) == sys.dgs[d].Q_limit[2]
            end
        end
        @testset "pᴴᶜ" begin
            @testset "Start values" begin
                @test start_value(pᴴᶜ) == 0.0
            end
            @testset "Bounds" begin
                @test lower_bound(pᴴᶜ) == 0.0
                @test has_upper_bound(pᴴᶜ) == false
            end
        end

    end

    return sot
end


function runtests()

    @testset "Estimator" begin
        for case in [case3_dist, case33]
            sys, name = case()
            @testset "$name" begin
                test_build_sets(sys)
                sot = Model()
                sot = test_add_variables(sot, sys)
            end
        end
    end
end

end

TestEstimator.runtests()