module DistSystem
using DataFrames

export Substation, DG, System, factory_system, null_der, DER

include("Tools.jl")
using .Tools: make_Y_bus
import DataFrames: DataFrame


struct DG
    bus
    P_limit
    Q_limit
    Cost
end

struct DER
    bus::Any
    S_limit::Float64
    energy::Float64
    alpha::Float64
    beta::Float64
    P_limit::Vector{Float64}
    Q_limit::Vector{Float64}
    scenario::Vector{Float64}
    Cost::Vector{Float64}
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
    amp
    m_load
    m_new_dg
    time_curr
    substation
    dgs
    Bsh
    buses
    System() = new()
end

function null_der(buses::Vector)::DER
    return DistSystem.DER(buses[2],
        0.0, 0.0, 0.0, 1.0, [0.0, 0.0], [0.0, 0.0], [0.0], [0.0, 0.0, 0.0]
    )
end

function factory_system(data::DataFrame, VL::Float64, VH::Float64, sub::Substation)
    sys = System()

    ### System's Data
    Sᴺ = 1e6
    Iᴺ = Sᴺ / (sub.nominal_voltage * sqrt(3))
    Zᴺ = (sub.nominal_voltage^2) / Sᴺ
    Yᴺ = 1 / Zᴺ

    sys.time_curr = 0.0
    sys.Y = make_Y_bus(data, sub.nominal_voltage) / Yᴺ
    sys.nbuses = size(sys.Y)[1]
    sys.VL = VL
    sys.VH = VH
    sys.m_load = [1.0]
    sys.m_new_dg = [[0.0]]
    sys.PL = collect(skipmissing(data.P_MW))
    sys.QL = collect(skipmissing(data.Q_MVAr))
    sys.buses = collect(skipmissing(data.Bus))
    sys.Bsh = (-(collect(skipmissing(data.Bshunt_MVAr)) * 1e6) ./ (sub.nominal_voltage^2)) / Yᴺ

    amp_pu = collect(skipmissing(data.Amp_pu))
    fb = collect(skipmissing(data.FB))
    tb = collect(skipmissing(data.TB))
    sys.amp = Dict((fb[k], tb[k]) => amp_pu[k] for k = 1:length(amp_pu))
    null_dg = null_der(sys.buses)
    sys.dgs = [null_dg]

    sys.substation = sub


    return sys

end

end