using HCEstimator
using JuMP, Ipopt
using DataFrames, CSV

data = DataFrame(CSV.File("example/case33.csv"))

sub = DistSystem.Substation(
    12660,              # Nominal voltage (V)
    1,                  # Bus
    1.0,                # Vˢᴮ: Voltage (p.u.)
    4.0,                # Pˢᴮ: Active power capacity (MW)
    2.5,                # Qˢᴮ: Reactive power capacity (MVAr)
    [0.003, 12, 240]    # Costs (Not used)
    )

sys = DistSystem.factory_system(
    data,               # Dataframe of the distribution system
    0.93,               # V_low: Voltage lower bound (p.u.)
    1.05,               # V_upper: Voltage upper bound (p.u.)
    sub                 # DistSystem.Sustation
    )

der1 = DistSystem.DER(
    18,                  # Bus
    0.02,                # Sᴰᴱᴿ (MVA)
    0.05,                # αᴰᴱᴿ
    [0.0, 0.03],         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
    [-0.03, 0.03],       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
    [0.0, 1.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
    [0.0026, 10.26, 210] # Costs (Not used) 
) #DG dispatchable

sys.dgs = [
    der1,
    DistSystem.DER(22, 0.02, 0.05, [0.0, 0.0], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-active dispatchable
    DistSystem.DER(33, 0.02, 0.05, [-0.01, 0.01], [-0.01, 0.01], [-1.0, 0.0, 1.0], [0.0026, 10.26, 210]), #ESS
    DistSystem.DER(25, 0.02, 0.0, [0.0, 0.0], [0.0, 0.0], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-dispatchable
]

sys.m_load = [0.5, 0.8, 1.0] # μᴸ
sys.m_new_dg = [-1.0, 0.0, 1] # μᴴᶜ

model = build_model(Model(Ipopt.Optimizer), sys)
set_silent(model)

optimize!(model)
println("Hosting Capacity: ", round(objective_value(model), digits = 3), " MVA")

(Ω, bΩ, L, K, D, S) = Tools.Get.sets(sys)

## Voltage magnitude and power injection
dims_bus = Tuple(length(set) for set in (Ω, L, K, S))
V = zeros(Float64, dims_bus)
P = zeros(Float64, dims_bus)
Q = zeros(Float64, dims_bus)

## Power of DERs installed used by DisCO
dims_der = Tuple(length(set) for set in (D, L, K, S))
Pᴰᴱᴿ = zeros(Float64, dims_der)
Qᴰᴱᴿ = zeros(Float64, dims_der)

for b = Ω, l = L, k = K, s = S, d = D
    V[b, l, k, s] = Tools.Get.voltage_module(model, b, l, k, s)
    P[b, l, k, s] = Tools.Get.power_active(model, b, l, k, s)
    Q[b, l, k, s] = Tools.Get.power_reactive(model, b, l, k, s)
    Pᴰᴱᴿ[d, l, k, s] = Tools.Get.power_active_DER(model, d, l, k, s)
    Qᴰᴱᴿ[d, l, k, s] = Tools.Get.power_reactive_DER(model, d, l, k, s)
end