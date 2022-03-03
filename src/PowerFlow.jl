module PowerFlow
using JuMP

export factory_model

function nl_pf(model, sys)
    G = real(sys.Y)
    B = imag(sys.Y)

    VH = sys.VH
    VL = sys.VL
    sub = sys.substation
    dgs = sys.dgs

    Pdg_limit = [dg.P_limit for dg in dgs]
    Qdg_limit = [dg.Q_limit for dg in dgs]
    set_dgs = 1:length(dgs)

    load_scenario = 1:length(sys.m_load)

    m_scenario_new_dg = sys.m_new_dg
    set_types_new_dg = 1:length(m_scenario_new_dg)    
    set_scenarios_new_dg = [1:length(scenario) for scenario in m_scenario_new_dg]

    buses = collect(1:sys.nbuses)

    @variable(model, -VL <= Vre[buses, load_scenario, k = set_types_new_dg, set_scenarios_new_dg[k]] <= VH, start = 1.0)
    @variable(model, -VL <= Vim[buses, load_scenario, k = set_types_new_dg, set_scenarios_new_dg[k]] <= VH, start = 0.0)
    @variable(model, 0 <= Pdg[i = set_dgs, load_scenario, k = set_types_new_dg, set_scenarios_new_dg[k]] <= Pdg_limit[i], start = 0.0)
    @variable(model, 0 <= Qdg[i = set_dgs, load_scenario, k = set_types_new_dg, set_scenarios_new_dg[k]] <= Qdg_limit[i], start = 0.0)

    #Squared Voltage Module
    @expression(model, V²[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Vre[b, l, k, s]^2 + Vim[b, l, k, s]^2
    )

    #Real Current
    @expression(model, Ire[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        sum(
            G[b, j] * Vre[j, l, k, s] - B[b, j] * Vim[j, l, k, s]
            for j in buses
        )
    )

    #Imaginary Current
    @expression(model, Iim[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        sum(
            B[b, j] * Vre[j, l, k, s] + G[b, j] * Vim[j, l, k, s]
            for j in buses
        )
    )

    #Squared Current Module
    @expression(model, I²[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Ire[b, l, k, s]^2 + Iim[b, l, k, s]^2
    )

    #Real Current Flow
    @expression(model, Iijre[i = buses, j=buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        (Vre[i, l, k, s] - Vre[j, l, k, s])*G[i,j] - (Vim[i, l, k, s] - Vim[j, l, k, s])*B[i,j]
    )

    #Imaginary Current Flow
    @expression(model, Iijim[i = buses, j=buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        (Vre[i, l, k, s] - Vre[j, l, k, s])*B[i,j] + (Vim[i, l, k, s] - Vim[j, l, k, s])*G[i,j]        
    )

    #Squared Current Flow Module
    @expression(model, I²ij[i = buses, j=buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Iijre[i,j,l,k,s]^2 + Iijim[i,j,l,k,s]^2
    )

    #Active Power
    @expression(model, P[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Vre[b, l, k, s] * Ire[b, l, k, s] + Vim[b, l, k, s] * Iim[b, l, k, s]
    )

    #Reactive Power
    @expression(model, Q[b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Vim[b, l, k, s] * Ire[b, l, k, s] - Vre[b, l, k, s] * Iim[b, l, k, s]
    )

    #Losses
    @expression(model, Ploss[l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]], sum(P[b, l, k, s] for b in buses))

    #Voltage Constraint
    for b = buses, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]
        @constraints(model, begin
            V²[b, l, k, s] <= VH^2
            V²[b, l, k, s] >= VL^2
        end)
    end

    # Substation Constraints
    for l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]
        @constraints(model, begin
            P[sub.bus, l, k, s] >= 0.0
            P[sub.bus, l, k, s] <= sub.P_limit
            Q[sub.bus, l, k, s] >= 0.0
            Q[sub.bus, l, k, s] <= sub.Q_limit
            I²[sub.bus, l, k, s] >= 0.0
            Vre[sub.bus, l, k, s] == sub.voltage
            Vim[sub.bus, l, k, s] == 0.0
        end)
    end

    return model
end


function costs(model, sys)
    load_scenario = 1:length(sys.m_load)

    m_scenario_new_dg = sys.m_new_dg
    set_types_new_dg = 1:length(m_scenario_new_dg)    
    set_scenarios_new_dg = [1:length(scenario) for scenario in m_scenario_new_dg]

    dgs = sys.dgs
    set_dgs = 1:length(dgs)

    P = model[:P]
    Pdg = model[:Pdg]

    sub = sys.substation

    @NLexpression(model, C_sub[l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        sub.Cost[3] * P[sub.bus, l, k, s]^2 + sub.Cost[2] * P[sub.bus, l, k, s] + sub.Cost[1]
    )

    @expression(model, C_dg[d = set_dgs, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        dgs[d].Cost[3] * Pdg[d, l, k, s]^2 + dgs[d].Cost[2] * Pdg[d, l, k, s] + dgs[d].Cost[1]
    )

    @NLexpression(model, Total_cost[l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        C_sub[l, k, s] +
        sum(
            C_dg[d, l, k, s]
            for d in set_dgs
        )
    )

    return model
end

function dg_and_loads(model, sys)

    load_scenario = 1:length(sys.m_load)
    m_load = sys.m_load

    m_scenario_new_dg = sys.m_new_dg
    set_types_new_dg = 1:length(m_scenario_new_dg)    
    set_scenarios_new_dg = [1:length(scenario) for scenario in m_scenario_new_dg]

    PL = sys.PL
    QL = sys.QL

    sub = sys.substation

    dgs = sys.dgs
    set_dgs = 1:length(dgs)

    dgs_bus = [dg.bus for dg in dgs]
    buses = 1:sys.nbuses
    buses_no_sub = collect(i for i in buses if i != sub.bus)
    buses_nodg = collect(i for i in buses_no_sub if !(i in dgs_bus))

    P = model[:P]
    Q = model[:Q]


    ## Power  for buses without DisCo's DGs
    @variable(model, Pnew[set_types_new_dg] >= 0, start = 0.0)

    @constraint(model, q[b = buses_nodg, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Q[b, l, k, s] == -m_load[l] * QL[b]
    )
    @constraint(model, p_no_dg[b = buses_nodg, l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        P[b, l, k, s] == -m_load[l] * PL[b] + m_scenario_new_dg[k][s]*Pnew[k]
    )

    ## Active  for buses with DisCo's DGs
    @variable(model, Pnew_dg[set_dgs, set_types_new_dg] >= 0, start = 0.0)
    Pdg = model[:Pdg]
    Qdg = model[:Qdg]
    @constraint(model, q_w_dg[d = set_dgs, b = dgs_bus[d], l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        Q[b, l, k, s] == -m_load[l] * QL[b] + Qdg[d, l, k, s]
    )
    @constraint(model, p_w_dg[d = set_dgs, b = dgs_bus[d], l = load_scenario, k = set_types_new_dg, s = set_scenarios_new_dg[k]],
        P[b, l, k, s] == -m_load[l] * PL[b] + Pdg[d, l, k, s] + m_scenario_new_dg[k][s]*Pnew_dg[d,k]
    )


    @constraint(model, limit_w[d = set_dgs, k= set_types_new_dg],
        Pnew_dg[d, k] <= Pnew[k]
    )

    return model
end

function factory_objective(model, sys)
    m_scenario_new_dg = sys.m_new_dg
    set_types_new_dg = 1:length(m_scenario_new_dg)
    dgs = sys.dgs
    set_dgs = 1:length(dgs)    

    Ploss = model[:Ploss]
    Pnew_dg = model[:Pnew_dg]
    Pnew = model[:Pnew]

    @expression(model, all_loses, sum(sum(sum(Ploss))))

    @expression(model, HC[k=set_types_new_dg], Pnew[k]*sys.nbuses + sum(Pnew_dg[d,k] for d in set_dgs))

    @objective(model, Max, sum(model[:HC]))

    return model


end

function factory_model(model, sys)
    model = nl_pf(model, sys)
    model = costs(model, sys)    
    model = dg_and_loads(model, sys)
    model = factory_objective(model, sys)   

    return model    
end

end
