module TestSimplePF
using Test
using JuMP, Ipopt
using DataFrames, CSV
using Printf

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
    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [1.0, 2, 3])
    data = DataFrame(CSV.File("tests/case3_dist.csv"))
    return DistSystem.factory_system(data, VL, VH, sub)
end

function test_complex_multiplication()
    z1 = 1 + -4im
    z2 = -2 + 5im
    z3 = z1 * z2
    z1v = [real(z1), imag(z1)]
    z2v = [real(z2), imag(z2)]

    z3re = SimplePF.mc_re(z1v[1], z1v[2], z2v[1], z2v[2])
    z3im = SimplePF.mc_im(z1v[1], z1v[2], z2v[1], z2v[2])

    @testset "test_complex_multiplication" begin
        @test z3re == real(z3)
        @test z3im == imag(z3)
    end

end

function test_add_variables(sot, sys)
    sot = SimplePF.add_variables(sot, sys)
    @testset "add_variables" begin
        @test sot isa Model
        @test num_variables(sot) == sys.nbuses*2

        @testset "V[$(i)]" for i = sys.buses
            @testset "Start values" begin
                @test start_value(sot[:V][:Re, i]) == 1.0
                @test start_value(sot[:V][:Im, i]) == 0.0
            end

            @testset "Lower bound" begin
                @test lower_bound(sot[:V][:Re, i]) == -sys.VH
                @test lower_bound(sot[:V][:Im, i]) == -sys.VH
            end
            @testset "Upper bound" begin
                @test upper_bound(sot[:V][:Re, i]) == sys.VH
                @test upper_bound(sot[:V][:Im, i]) == sys.VH
            end
        end
    end

    return sot

end

function test_add_voltage_constraints(sot, sys)
    sot = SimplePF.add_voltage_constraints(sot, sys)
    @test sot isa Model

    voltage_constraint = sot[:voltage_constraint]
    V² = sot[:V²]
    V_module = sot[:V_module]
    V = sot[:V]


    @testset "add_voltage_constraints" for i = sys.buses
        @testset "V²" begin
            @test V²[i] isa QuadExpr
            @test V²[i] == V[:Re, i]^2 + V[:Im, i]^2
        end
        @testset "voltage_constraint" begin
            obj = constraint_object(voltage_constraint[i])
            @test isequal_canonical(obj.func, V²[i])
            @test obj.set == MOI.Interval(sys.VL^2, sys.VH^2)
        end
    end
    return sot
end

function test_add_I_V_relationship(sot, sys)
    sot = SimplePF.add_I_V_relationship(sot, sys)
    @test sot isa Model
    V = sot[:V]
    I = sot[:I]
    G = real(sys.Y)
    B = imag(sys.Y)

    @testset "add_I_V_relationship" for i = sys.buses
        @testset "Iᴿᵉ" begin
            @test I[:Re, i] == sum(G[i, j] * V[:Re, j] for j in sys.buses) - sum(B[i, j] * V[:Im, j] for j in sys.buses)
        end
        @testset "Iᴵᵐ" begin
            @test I[:Im, i] == sum(B[i, j] * V[:Re, j] for j in sys.buses) + sum(G[i, j] * V[:Im, j] for j in sys.buses)
        end
    end
    return sot
end

function test_add_S_VI_relationship(sot, sys)
    sot = SimplePF.add_S_VI_relationship(sot, sys)
    @test sot isa Model
    V = sot[:V]
    I = sot[:I]
    P = sot[:P]
    Q = sot[:Q]

    @testset "add_S_VI_relationship" for i = sys.buses
        @test P[i] == SimplePF.mc_re(V[:Re, i], V[:Im, i], I[:Re, i], -I[:Im, i])
        @test Q[i] == SimplePF.mc_im(V[:Re, i], V[:Im, i], I[:Re, i], -I[:Im, i])
    end
    return sot
end

function test_add_substation_constraint(sot, sys)
    sot = SimplePF.add_substation_constraint(sot, sys)
    @test sot isa Model

    V = sot[:V]
    I = sot[:I]
    P = sot[:P]
    Q = sot[:Q]
    i = sys.substation.bus
    Plimit = float(sys.substation.P_limit)
    Qlimit = float(sys.substation.Q_limit)

    @testset "add_substation_constraint" begin
        @testset "Voltage" begin
            @test is_fixed(V[:Re, i])
            @test is_fixed(V[:Im, i])
            @test fix_value(V[:Re, i]) == 1.0
            @test fix_value(V[:Im, i]) == 0
        end
        @testset "Power" begin
            @testset "Active" begin
                obj = constraint_object(sot[:sub_plimit])
                @test obj.set == MOI.Interval(0.0, Plimit)
                @test isequal_canonical(obj.func, P[i])
            end

            @testset "Reactive" begin
                obj = constraint_object(sot[:sub_qlimit])
                @test obj.set == MOI.Interval(0.0, Qlimit)
                @test isequal_canonical(obj.func, Q[i])
            end
        end

        @testset "Current" begin
            obj = constraint_object(sot[:sub_current])
            @test isequal_canonical(obj.func, I[:Re, i]^2 + I[:Im, i]^2)
            @test obj.set == MOI.GreaterThan(0.0)
        end

    end
    return sot
end

function test_add_power_injection_definition(sot, sys)
    sot = SimplePF.add_power_injection_definition(sot, sys)
    PL = sys.PL
    QL = sys.QL
    subbus = sys.substation.bus
    p = sot[:p]
    q = sot[:q]
    P = sot[:P]
    Q = sot[:Q]

    @testset "add_power_injection_definition" begin
        @testset "No definition for substation bus" begin
            @test_throws KeyError p[subbus]
            @test_throws KeyError q[subbus]

        end
        @testset "Active" for i = [i for i = sys.buses if i != subbus]
            obj = constraint_object(p[i])
            @test isequal_canonical(obj.func, P[i])
            @test obj.set == MOI.EqualTo(-PL[i])
        end
        @testset "Reactive" for i = [i for i = sys.buses if i != subbus]
            obj = constraint_object(q[i])
            @test isequal_canonical(obj.func, Q[i])
            @test obj.set == MOI.EqualTo(-QL[i])
        end
    end

    return sot
end

function test_nl_pf(sot, sys, case)

    other_sys, name = case()
    model = SimplePF.nl_pf(Model(), other_sys)
    @testset "nl_pf" begin
        #Find a better way to test it 
        @test sprint(print, sot) == sprint(print, model)
    end
    return sot
end

function util_test_case!(model, name, V_expected, angle_expected)

    @testset "solve $name" begin
        set_optimizer(model, Ipopt.Optimizer)
        set_silent(model)
        optimize!(model)
        @test termination_status(model) == LOCALLY_SOLVED
        @test primal_status(model) == FEASIBLE_POINT
        V = value.(model[:V_module])
        θ = value.(model[:V_angle_deg])
        @testset "Voltage: Bus $i" for (i, returned) in enumerate(V)
            @test V_expected[i] .≈ returned atol = 1e-3
        end
        @testset "Angle: Bus $i" for (i, returned) in enumerate(θ)
            @test angle_expected[i] .≈ returned atol = 1e-3
        end
    end
end

function test_solve_case3_dist()

    V_expected = [1.000 0.964 0.951]
    angle_expected = [0.0 -1.826 -2.644]
    model = SimplePF.nl_pf(Model(), case3_dist())
    util_test_case!(model, "case3_dist", V_expected, angle_expected)

end

function runtests()
    @testset "SimplePF" begin
        for case in [case3_dist]
            sys, name = case()
            @testset "$name" begin
                sot = Model()
                sot = test_add_variables(sot, sys)
                sot = test_add_voltage_constraints(sot, sys)
                sot = test_add_I_V_relationship(sot, sys)
                sot = test_add_S_VI_relationship(sot, sys)
                sot = test_add_substation_constraint(sot, sys)
                sot = test_add_power_injection_definition(sot, sys)
                sot = test_nl_pf(sot, sys, case)
            end
        end
        test_complex_multiplication()
    end
end
end


TestSimplePF.runtests()