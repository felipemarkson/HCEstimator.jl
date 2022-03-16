module SimplePF
using JuMP

export factory_model

mc_re(a, b, c, d) = a * c - b * d # Real( (a + ib) * (c + id) )
mc_im(a, b, c, d) = a * d + b * c # Imag( (a + ib) * (c + id) )
ε = 1e-5

function add_variables(model, sys)
    @variable(model, -sys.VH <= V[[:Re, :Im], sys.buses] <= sys.VH)
    for i = sys.buses
        set_start_value.(V[:Re, i], 1.0)
        set_start_value.(V[:Im, i], 0.0)
    end

    return model
end

function add_voltage_constraints(model, sys)

    calc_angle(a, b) = rad2deg(angle(a + 1im * b))
    register(model, :calc_angle, 2, calc_angle; autodiff = true)

    V = model[:V]

    @expression(model, V²[i = sys.buses], V[:Re, i]^2 + V[:Im, i]^2)
    @NLexpression(model, V_module[i = sys.buses], sqrt(V²[i]))
    @NLexpression(model, V_angle_deg[i = sys.buses], calc_angle(V[:Re, i], V[:Im, i]))

    @constraint(model, voltage_constraint[i = sys.buses],
        sys.VL^2 <= V²[i] <= sys.VH^2
    )

    return model
end

function add_I_V_relationship(model, sys)
    #  I = Y*V
    #  Ref: On the numerical solving of complex linear systems https://ijpam.eu/contents/2012-76-1/11/11.pdf
    #  |Ire|   |G   -B|   |Vre|
    #  |   | = |      | * |   |
    #  |Iim|   |B    G|   |Vim|

    G = real.(sys.Y)
    B = imag.(sys.Y)
    V = model[:V]
    @expression(model, I[z = [:Re, :Im], i = sys.buses],
        if z == :Re
            sum(
                G[i, j] * V[:Re, j] - B[i, j] * V[:Im, j]
                for j in sys.buses
            )
        elseif z == :Im
            sum(
                B[i, j] * V[:Re, j] + G[i, j] * V[:Im, j]
                for j in sys.buses
            )
        end
    )
    return model
end

function add_S_VI_relationship(model, sys)
    #   Si = Vi x Ii*
    V = model[:V]
    I = model[:I]
    @expression(model, P[i = sys.buses],
        mc_re(V[:Re, i], V[:Im, i], I[:Re, i], -I[:Im, i])
    )

    @expression(model, Q[i = sys.buses],
        mc_im(V[:Re, i], V[:Im, i], I[:Re, i], -I[:Im, i])
    )
    return model
end

function add_active_losses(model, sys)
    P = model[:P]
    @expression(model, Ploss,
        sum(P[i] for i = sys.buses)
    )
    return model
end

function add_reactive_losses(model, sys)
    Q = model[:Q]
    @expression(model, Qloss,
        sum(Q[i] for i = sys.buses)
    )
    return model
end

function add_substation_constraint(model, sys)
    V = model[:V]
    I = model[:I]
    P = model[:P]
    Q = model[:Q]
    sub = sys.substation
    fix(V[:Re, sub.bus], sub.voltage, force = true)
    fix(V[:Im, sub.bus], 0.0, force = true)

    @constraint(model, sub_plimit,
        0 <= P[sub.bus] <= sub.P_limit
    )
    @constraint(model, sub_qlimit,
        0 <= Q[sub.bus] <= sub.Q_limit
    )

    @constraint(model, sub_current,
        I[:Re, sub.bus]^2 + I[:Im, sub.bus]^2 >= 0.0
    )

    return model
end

function add_power_injection_definition(model, sys)

    buses_wout_sub = collect(i for i = 1:sys.nbuses if i != sys.substation.bus)
    Q = model[:Q]
    P = model[:P]

    @constraint(model, q[i = buses_wout_sub],
        Q[i] == -sys.QL[i]
    )
    @constraint(model, p[i = buses_wout_sub],
        P[i] == -sys.PL[i]
    )

    return model
end

function nl_pf(model, sys)
    model = add_variables(model, sys)
    model = add_voltage_constraints(model, sys)
    model = add_I_V_relationship(model, sys)
    model = add_S_VI_relationship(model, sys)
    model = add_active_losses(model, sys)
    model = add_reactive_losses(model, sys)
    model = add_substation_constraint(model, sys)
    model = add_power_injection_definition(model, sys)
    return model
end


function costs(model, sys)
    P = model[:P]
    sub = sys.substation

    @NLexpression(model, cost_substation,
        sub.Cost[3] * P[sub.bus]^2 + sub.Cost[2] * P[sub.bus] + sub.Cost[1]
    )
    return model
end

function add_objective(model, sys)
    @NLobjective(model, Min, model[:cost_substation])
    return model
end

function factory_model(model, sys)
    model = nl_pf(model, sys)
    return add_objective(model, sys)
end

end
