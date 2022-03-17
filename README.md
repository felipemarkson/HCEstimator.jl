<!-- INPUT FILE TO README FOR readme2tex! -->

# Hosting Capacity Estimator

This library provides a Distributed Energy Resources' Hosting Capacity estimation of distribution systems considering that the Distribution Company can partially dispatch other DERs installed in the system.

## Getting Started

### Data Format

The ```DistSystem.System``` structure expected a [DataFrames.jl](https://dataframes.juliadata.org/stable/) with the follow columns:
```
Row │ Branch  FB     TB     Type     R_Ohm    X_ohm    Bus      P_MW        Q_MVAr      Bshunt_MVAr
    │ Int64   Int64  Int64  String   Float64  Float64  Int64    Float64     Float64     Float64
────┼──────────────────────────────────────────────────────────────────────────────────────────────────
```
The active branches must have "Fixed" in ```Type``` field.

### Dependencies

You will need [Julia](https://julialang.org/) v1.6 or greater, [JuMP.jl](https://jump.dev/)  v0.23 or greater, and a nonlinear solver compatible with [JuMP.jl](https://jump.dev/) and the model described below.

### Exemple of use

This exemple also can be found in [example.jl](example/example.jl).

The distribution system of the example is also available in [Dolatabadi et. al. (2021)](https://ieeexplore.ieee.org/document/9258930).

```julia
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
```

## Mathematical Model

This library uses the following model:


<img src="svgs/d14abed1a5115037397da740c933f4dc.svg?invert_in_darkmode" align=middle width=35.15994899999999pt height=14.15524440000002pt/> 


<p align="center"><img src="svgs/9440c3753d7bb170f2ba3e904f295d29.svg?invert_in_darkmode" align=middle width=194.91340605pt height=29.58934275pt/></p>

 
<img src="svgs/9dc19dc073dbefeb7f85c0f086c9ec27.svg?invert_in_darkmode" align=middle width=22.009199849999987pt height=20.221802699999984pt/>


<p align="center"><img src="svgs/6257bcc9d6bb1be9fabb2f047b0a15a6.svg?invert_in_darkmode" align=middle width=459.40233405pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/39c4bae6cb3acc2e715d991e0a85dab2.svg?invert_in_darkmode" align=middle width=454.9440225pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/9b30c7275cfd7d1824970757c6dbfadb.svg?invert_in_darkmode" align=middle width=360.06316664999997pt height=118.35736770000001pt/></p>


<p align="center"><img src="svgs/140c4fc7f4941ce36d531461eecea83c.svg?invert_in_darkmode" align=middle width=350.37468345pt height=49.315569599999996pt/></p>

<p align="center"><img src="svgs/6cf6441e282f47db0b45579b54503b07.svg?invert_in_darkmode" align=middle width=343.48524705pt height=118.35736770000001pt/></p>

<p align="center"><img src="svgs/b4a0fa9fc2087e118d5c97ddb9dc0a0b.svg?invert_in_darkmode" align=middle width=438.00400709999997pt height=120.20846475pt/></p>

<p align="center"><img src="svgs/da595163b53361844b1b6488c5e5c679.svg?invert_in_darkmode" align=middle width=365.81203724999995pt height=69.0417981pt/></p>

<!-- <p align="center"><img src="svgs/e45858c011938cbd92291e86b38f0383.svg?invert_in_darkmode" align=middle width=60.913292549999994pt height=29.58934275pt/></p> -->



## Nomenclature

### Variables

<img src="svgs/2b7c31b7df641cd2ffc8154ea6e90540.svg?invert_in_darkmode" align=middle width=30.15119909999999pt height=27.6567522pt/>: Active power injection to HC calculation

<img src="svgs/381d927132be502dc51700a3c9e7b99b.svg?invert_in_darkmode" align=middle width=39.61762199999999pt height=27.6567522pt/>: Active power injection of DERs dispached by DisCo.

<img src="svgs/4c684c9947c8124eb646279e030febe5.svg?invert_in_darkmode" align=middle width=39.27514304999999pt height=27.6567522pt/>: Reactive power injection of DERs dispached by DisCo.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p,&space;q" title="\bg_white p, q" />: Nodal active and reactive power injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;i^{\Re},&space;i^{\Im}" title="\bg_white i^{\Re}, i^{\Im}" />: Real and imaginary part of nodal current injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;v^{\Re},&space;v^{\Im}" title="\bg_white v^{\Re}, v^{\Im}" />: Real and imaginary part of nodal voltage


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Buses' set excluded substation bus and DERs buses

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

<img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>: Set of all possible combinations of operation of DERs' Owner

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

<img src="svgs/5de3395d9a962facf1228570f1570c3e.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=36.6389529pt/>: Upper limits of active and reactive power that can be dispached by DERs.

<img src="svgs/5b087afcef448f22d28d062ec207a5bf.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=30.063960299999987pt/>: Lower limits of active and reactive power that can be dispached by DERs.

<img src="svgs/8a57ec50a9fa4dfedfe3cc701d1153a9.svg?invert_in_darkmode" align=middle width=42.37443869999999pt height=27.6567522pt/>: DERs' power limit.

<img src="svgs/a2369470b5770634fad738b057fd1609.svg?invert_in_darkmode" align=middle width=41.923553099999985pt height=27.6567522pt/>: Proportion of DERs' power limit that can be dispached by DisCo.

<img src="svgs/fae5399046b45871e8d75acb5fda8054.svg?invert_in_darkmode" align=middle width=44.18382704999999pt height=27.6567522pt/>: DERs' owner power injection capacity. <img src="svgs/1f4b9873ee655894fbfe1455ad442377.svg?invert_in_darkmode" align=middle width=193.1390175pt height=27.6567522pt/>

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{SB}},&space;\overline{Q^{SB}}" title="\bg_white \overline{P^{SB}}, \overline{Q^{SB}}" />: Active and reactive limit of the substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^L" title="\bg_white \mu^L" />: Load scenario multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^{HC}" title="\bg_white \mu^{HC}" />: Scenario multiplier for HC calculation

<img src="svgs/777d440c6c333beeb18498c6d177104f.svg?invert_in_darkmode" align=middle width=41.25197999999999pt height=27.6567522pt/>: DERs' Owner Operation scenario

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;N^B" title="\bg_white N^B" />: Quantity of buses without DGs and substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b^{SB}" title="\bg_white b^{SB}" />: Substation's bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b_{d}" title="\bg_white b_{d}" /> : DG's bus

## Roadmap

- [x] Define the model

- [x] Implement the model on JuMP.jl

- [x] High-level interface for HC estimation

- [x] Initial documentation

- [x] Implement the minimization of costs.

- [x] Validate the model with Matpower.

- [ ] Implement changes on system's topology.

- [x] Implement tests for power flow calculation using a simple system

- [x] Implement tests for power flow calculation using the 33-bus

- [ ] Implement tests for others functions

- [x] Describe the relationship between the model and codebase

- [ ] Better Documentation