using HCEstimator
using JuMP, Ipopt
using DataFrames, CSV

VN = 12660
Sb = 1e6
Yb = Sb / (VN^2)

Vsub = 1.0
sub_P_limt = 4
sub_Q_limit = 2.5
bus_sub = 1
nbuses = 33
VL = 0.93
VH = 1.05
sub = DistSystem.Substation(VN, bus_sub, Vsub, sub_P_limt, sub_Q_limit, [0.003, 12, 240])
data = DataFrame(CSV.File("example/case33.csv"))
sys = DistSystem.factory_system(data, VL, VH, sub)
der1 = DistSystem.DER(
    18,                  # Bus
    0.02,                # Sᴰᴱᴿ (MVA)
    0.05,                # αᴰᴱᴿ
    [0.0, 0.03],         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
    [-0.03, 0.03],       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
    [0.0, 1.0],          # Operation Scenarios
    [0.0026, 10.26, 210] # Costs (Not used) 
) #DG dispatchable
sys.dgs = [
    der1,
    DistSystem.DER(22, 0.02, 0.05, [0.0, 0.0], [-0.03, 0.03], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-active dispatchable
    DistSystem.DER(33, 0.02, 0.05, [-0.01, 0.01], [-0.01, 0.01], [-1.0, 0.0, 1.0], [0.0026, 10.26, 210]), #ESS
    DistSystem.DER(25, 0.02, 0.0, [0.0, 0.0], [0.0, 0.0], [0.0, 1.0], [0.0026, 10.26, 210]), #DG non-dispatchable
]
sys.m_load = [0.5, 0.8, 1.0]
sys.m_new_dg = [-1.0, 0.0, 1]

model = build_model(Model(Ipopt.Optimizer), sys)

optimize!(model)
println("Hosting Capacity: ", round(objective_value(model), digits=3), " MVA")

## The code bellow takes several minutes to finished

# (Ω, bΩ, L, K, D, S) = Tools.Get.sets(sys)
# dimsV = Tuple(length(set) for set in (Ω, L, K, S))
# V = zeros(Float64, dimsV)
# dimsS = Tuple(length(set) for set in (D, L, K, S))
# Sᴰᴱᴿ = zeros(Complex, dimsS)

# for b = Ω, l = L, k = K, s = S, d = D
#     V[b, l, k, s] = Tools.Get.voltage_module(model, b, l, k, s)
#     Sᴰᴱᴿ[d, l, k, s] = Tools.Get.power_DER(model, d, l, k, s)
# end