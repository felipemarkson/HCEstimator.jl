module DistSystem

export Substation, DG, System, Get

include("Tools.jl")
using .Tools
import DataFrames: DataFrame


struct DG
    bus
    P_limit
    Q_limit
    Cost
end

struct Substation
    nominal_voltage
    bus
    voltage
    P_limit
    Q_limit
    Cost
end


mutable struct System
    Y
    nbuses
    VL
    VH
    PL
    QL
    m_load
    m_new_dg
    substation
    dgs
    Bsh
    System(data::DataFrame, VL::Float64, VH::Float64, sub::Substation) = factory_system(data::DataFrame, VL::Float64, VH::Float64, sub::Substation)
    System() = new()
end


function factory_system(data::DataFrame, VL::Float64, VH::Float64, sub::Substation)


    sys = System()

    ### System's Data
    Sᴺ = 1e6
    Iᴺ = Sᴺ / (sub.nominal_voltage * sqrt(3))
    Zᴺ = (sub.nominal_voltage^2) / Sᴺ
    Yᴺ = 1 / Zᴺ


    sys.Y = make_Y_bus(data, sub.nominal_voltage) / Yᴺ
    sys.nbuses = size(sys.Y)[1]
    sys.VL = VL
    sys.VH = VH
    sys.m_load = [1.0]
    sys.m_new_dg = [[0.0]]
    sys.PL = data.P_MW[1:sys.nbuses]
    sys.QL = data.Q_MVAr[1:sys.nbuses]
    sys.dgs = []
    sys.Bsh = (-(data.Bshunt_MVAr * 1e6) ./ (sub.nominal_voltage^2)) / Yᴺ

    sys.substation = sub


    return sys

end

module Get
using JuMP: value
export voltage, current, power, current_bsh, current_ij, power_dg, losses_ij, losses
voltage(model, bus, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Vre])[bus, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:Vim])[bus, l_scenario, type_dg_hc, scenario_hc]
current(model, bus, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Ire])[bus, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:Iim])[bus, l_scenario, type_dg_hc, scenario_hc]
power(model, bus, l_scenario, type_dg_hc, scenario_hc) = value.(model[:P])[bus, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:Q])[bus, l_scenario, type_dg_hc, scenario_hc]
current_bsh(model, bus, l_scenario, type_dg_hc, scenario_hc) = value.(model[:I_bsh_re])[bus, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:I_bsh_re])[bus, l_scenario, type_dg_hc, scenario_hc]
current_ij(model, i, j, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Iijre])[i, j, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:Iijim])[i, j, l_scenario, type_dg_hc, scenario_hc]
power_dg(model, nº, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Pdg])[nº, l_scenario, type_dg_hc, scenario_hc] + 1im * value.(model[:Pdg])[nº, l_scenario, type_dg_hc, scenario_hc]
losses_ij(model, i, j, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Ploss_ij])[i, j, l_scenario, type_dg_hc, scenario_hc]
losses(model, l_scenario, type_dg_hc, scenario_hc) = value.(model[:Ploss])[l_scenario, type_dg_hc, scenario_hc]
end

end