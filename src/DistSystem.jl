module DistSystem
using DataFrames

export Substation, DG, System, factory_system

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
    alpha::Float64
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
    m_load
    m_new_dg
    substation
    dgs
    Bsh
    buses
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
    sys.PL = collect(skipmissing(data.P_MW))
    sys.QL = collect(skipmissing(data.Q_MVAr))
    sys.dgs = []
    sys.Bsh = (-(collect(skipmissing(data.Bshunt_MVAr)) * 1e6) ./ (sub.nominal_voltage^2)) / Yᴺ

    sys.buses = collect(skipmissing(data.Bus))

    sys.substation = sub


    return sys

end

end