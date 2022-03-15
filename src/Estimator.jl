module Estimator
include("SimplePF.jl")
import .SimplePF
using JuMP

function build_sets(sys)
    sub_der = [Estimator.build_DER_set_buses(sys); sys.substation.bus]
    Ω = sys.buses
    bΩ = filter(bus -> bus ∉ sub_der, Ω)
    L = collect(1:length(sys.m_load))
    K = collect(1:reduce(*, length(der.scenario) for der in sys.dgs))
    D = collect(1:length(sys.dgs))
    S = collect(1:length(sys.m_new_dg))
    return (Ω, bΩ, L, K, D, S)
end

function build_DER_set_buses(sys)
    return [dg.bus for dg in sys.dgs]
end

function add_variables(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)


    @variable(model, -sys.VH ≤ V[[:Re, :Im], Ω, L, K, S] ≤ sys.VH)
    for b = Ω, l = L, k = K, s = S
        set_start_value.(V[:Re, b, l, k, s], 1.0)
        set_start_value.(V[:Im, b, l, k, s], 0.0)
    end
    @variable(model, sys.dgs[d].P_limit[1] ≤ pᴰᴱᴿ[d = D, L, K, S] ≤ sys.dgs[d].P_limit[2], start = 0.0)
    @variable(model, sys.dgs[d].Q_limit[1] ≤ qᴰᴱᴿ[d = D, L, K, S] ≤ sys.dgs[d].Q_limit[2], start = 0.0)
    @variable(model, 0.0 ≤ pᴴᶜ, start = 0.0)

    return model
end

function add_voltage_constraints(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    V = model[:V]

    @expression(model, V²[b = Ω, l = L, k = K, s = S],
        V[:Re, b, l, k, s]^2 + V[:Im, b, l, k, s]^2
    )

    @constraint(model, voltage_constraint[b = Ω, l = L, k = K, s = S],
        sys.VL^2 <= V²[b, l, k, s] <= sys.VH^2
    )

    @NLexpression(model, V_module[b = Ω, l = L, k = K, s = S],
        sqrt(V²[b, l, k, s])
    )

    return model
end

function add_I_V_relationship(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    G = real(sys.Y)
    B = imag(sys.Y)
    V = model[:V]
    @expression(model, I[z = [:Re, :Im], i = Ω, l = L, k = K, s = S],
        if z == :Re
            sum(
                G[i, j] * V[:Re, j, l, k, s] - B[i, j] * V[:Im, j, l, k, s]
                for j in Ω
            )
        elseif z == :Im
            sum(
                B[i, j] * V[:Re, j, l, k, s] + G[i, j] * V[:Im, j, l, k, s]
                for j in Ω
            )
        end
    )

    return model
end

function add_S_VI_relationship(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    V = model[:V]
    I = model[:I]

    @expression(model, P[b = Ω, l = L, k = K, s = S],
        SimplePF.mc_re(V[:Re, b, l, k, s], V[:Im, b, l, k, s], I[:Re, b, l, k, s], -I[:Im, b, l, k, s])
    )
    @expression(model, Q[b = Ω, l = L, k = K, s = S],
        SimplePF.mc_im(V[:Re, b, l, k, s], V[:Im, b, l, k, s], I[:Re, b, l, k, s], -I[:Im, b, l, k, s])
    )

    return model
end

function add_active_losses(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    P = model[:P]
    @expression(model, Ploss[l = L, k = K, s = S],
        sum(P[b, l, k, s] for b = Ω)
    )
    return model
end

function add_reactive_losses(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    Q = model[:Q]
    @expression(model, Qloss[l = L, k = K, s = S],
        sum(Q[b, l, k, s] for b = Ω)
    )
    return model
end

function add_substation_constraint(model, sys)
    (Ω, bΩ, L, K, D, S) = Estimator.build_sets(sys)
    V = model[:V]
    I = model[:I]
    P = model[:P]
    Q = model[:Q]
    sub = sys.substation
    for l = L, k = K, s = S
        fix(V[:Re, sub.bus, l, k, s], sub.voltage, force = true)
        fix(V[:Im, sub.bus, l, k, s], 0.0, force = true)
    end

    @constraint(model, sub_plimit[l = L, k = K, s = S],
        0 <= P[sub.bus, l, k, s] <= sub.P_limit
    )
    @constraint(model, sub_qlimit[l = L, k = K, s = S],
        0 <= Q[sub.bus, l, k, s] <= sub.Q_limit
    )

    @constraint(model, sub_current[l = L, k = K, s = S],
        I[:Re, sub.bus, l, k, s]^2 + I[:Im, sub.bus, l, k, s]^2 >= 0.0
    )


    return model
end

end