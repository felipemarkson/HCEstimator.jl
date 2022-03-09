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

struct Case
    name::String
    V_expected::Vector{Float64}
    angle_expected::Vector{Float64}
end

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
    case = Case(
        "case3_dist",
        [1.0000, 0.9641, 0.9511],
        [0.0, -1.8255, -2.6440]
    )
    sys = DistSystem.factory_system(data, VL, VH, sub)



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
    sub = DistSystem.Substation(VN, bus_sub, Vsub, P_limt, Q_limit, [1.0, 2, 3])
    data = DataFrame(CSV.File("tests/case33.csv"))
    sys = DistSystem.factory_system(data, VL, VH, sub)
    case = Case(
        "case33",
        [1.0000, 0.9973, 0.9848, 0.9785, 0.9723, 0.9583, 0.9563, 0.9520, 0.9475, 0.9435, 0.9428, 0.9416, 0.9383, 0.9378, 0.9376, 0.9375, 0.9396, 0.9403, 0.9968, 0.9932, 0.9925, 0.9919, 0.9813, 0.9746, 0.9713, 0.9568, 0.9547, 0.9468, 0.9412, 0.9386, 0.9379, 0.9382, 0.9398],
        [0, -0.0150, -0.0934, -0.1490, -0.2104, -0.5805, -0.8319, -0.8952, -1.1107, -1.3188, -1.3396, -1.3817, -1.6797, -1.8333, -1.9543, -2.0837, -2.3423, -2.4561, -0.0258, -0.0927, -0.1121, -0.1324, -0.1242, -0.2126, -0.2561, -0.5839, -0.5881, -0.7285, -0.8235, -0.8304, -1.1211, -1.2100, -1.2906]
    )
    return sys, case
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
        @test num_variables(sot) == sys.nbuses * 2

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

    other_sys, _ = case()
    model = SimplePF.nl_pf(Model(), other_sys)
    @testset "nl_pf" begin
        #Find a better way to test it 
        @test sprint(print, sot) == sprint(print, model)
    end
    return sot
end

function util_test_case!(model, sys, case)

    @testset "solve $(case.name)" begin
        set_optimizer(model, Ipopt.Optimizer)
        set_silent(model)
        optimize!(model)


        @testset "Optimization" begin
            @testset "Solved: $(termination_status(model))" begin
                @test termination_status(model) == LOCALLY_SOLVED
            end
            @testset "Feasible: $(primal_status(model))" begin
                @test primal_status(model) == FEASIBLE_POINT
            end
        end

        V = value.(model[:V_module])
        θ = value.(model[:V_angle_deg])
        @testset "Solution for Bus $i" for i = sys.buses
            v = round(V[i], digits = 4)
            ang = round(θ[i], digits = 4)
            @testset "Voltage: $v" begin
                @test case.V_expected[i] ≈ V[i] atol = 1e-4
            end
            @testset "Angle: $(ang)°" begin
                @test case.angle_expected[i] ≈ θ[i] atol = 1e-4
            end
        end
    end
end

function test_solve_case(case)
    sys, actual_case = case()
    model = SimplePF.nl_pf(Model(), sys)
    util_test_case!(model, sys, actual_case)

end

function runtests()
    @testset "SimplePF" begin
        for case in [case3_dist, case33]
            sys, actual_case = case()
            @testset "$(actual_case.name)" begin
                sot = Model()
                sot = test_add_variables(sot, sys)
                sot = test_add_voltage_constraints(sot, sys)
                sot = test_add_I_V_relationship(sot, sys)
                sot = test_add_S_VI_relationship(sot, sys)
                sot = test_add_substation_constraint(sot, sys)
                sot = test_add_power_injection_definition(sot, sys)
                sot = test_nl_pf(sot, sys, case)
                test_solve_case(case)
            end

        end
        test_complex_multiplication()
    end
end
end


TestSimplePF.runtests()