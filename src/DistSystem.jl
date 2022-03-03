module DistSystem

export Substation, DG, System

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
    System(data::DataFrame, VL::Float64, VH::Float64, sub::Substation) = factory_system(data::DataFrame, VL::Float64, VH::Float64, sub::Substation)
    System() = new()
end


function factory_system(data::DataFrame, VL::Float64, VH::Float64, sub::Substation)


    sys = System()

    ### System's Data
    Sᴺ = 1e6
    Iᴺ = Sᴺ / (sub.nominal_voltage * sqrt(3))
    Zᴺ = sub.nominal_voltage / Iᴺ
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

    sys.substation = sub


    return sys

end
end