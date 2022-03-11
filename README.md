<!-- INPUT FILE TO README FOR readme2tex! -->

# Hosting Capacity Estimator

This library provides a Distributed Generators (DGs) Hosting Capacity (HC) of distribution systems considering that Distribution Company (DisCo) owned other DGs installed in the system.

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

This exemple also can be found in [example.jl](example.jl).

The distribution system of the example is also available in [Dolatabadi et. al. (2021)](https://ieeexplore.ieee.org/document/9258930).

```julia
using CSV, DataFrames
using JuMP
using Ipopt

using HCEstimator


data = DataFrame(CSV.File("exemple_data.csv"))

VL = 0.95   #Lower limit voltage
VH = 1.05  #Higher limit voltage

sub = DistSystem.Substation(
    12600.0,                # Nominal Voltage
    1,                      # Bus
    1.,                     # Voltage(p.u)
    4.,                     # Active power limit(MW)
    2.5,                    # Reactive power limit(MVAr)
    [240.0, 12.0, 0.003]    # Costs [Fixed, Linear, Quadratic]
)

dg1 = DistSystem.DG(
    18,                     # Bus
    0.2,                    # Active power limit(MW)
    0.0,                    # Reative power limit(MW)
    [210; 10.26; 0.0026]    # Costs [Fixed, Linear, Quadratic]
)

sys = DistSystem.System(data, VL, VH, sub)

sys.dgs = [
    dg1,
    DistSystem.DG(22, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(25, 0.2, 0.,[210; 10.26; 0.0026]),
    DistSystem.DG(33, 0.2, 0.,[210; 10.26; 0.0026])
]
sys.m_load = collect(0.6:0.2:1) # Load Multipliers
sys.m_new_dg = [
    collect(0.0:0.2:1) # Generic generator Multipliers
]

model = Model(Ipopt.Optimizer)  # Create a JuMP model
model = build_model(model, sys) # Build the HC model
optimize!(model)                # Optimize!

println("Hosting Capacity: ", objective_value(model))
```

## Mathematical Model

This library uses the following model:


<img src="svgs/d14abed1a5115037397da740c933f4dc.svg?invert_in_darkmode" align=middle width=35.15994899999999pt height=14.15524440000002pt/> 


<p align="center"><img src="svgs/9440c3753d7bb170f2ba3e904f295d29.svg?invert_in_darkmode" align=middle width=194.91340605pt height=29.58934275pt/></p>

 
<img src="svgs/9dc19dc073dbefeb7f85c0f086c9ec27.svg?invert_in_darkmode" align=middle width=22.009199849999987pt height=20.221802699999984pt/>


<p align="center"><img src="svgs/931940eb20c39d40451c2c3521091032.svg?invert_in_darkmode" align=middle width=363.8212578pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/ed6c42b3d7ccc4a6af275e5ca6c0b908.svg?invert_in_darkmode" align=middle width=454.9440225pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/9b30c7275cfd7d1824970757c6dbfadb.svg?invert_in_darkmode" align=middle width=360.06316664999997pt height=118.35736770000001pt/></p>


<p align="center"><img src="svgs/140c4fc7f4941ce36d531461eecea83c.svg?invert_in_darkmode" align=middle width=350.37468345pt height=49.315569599999996pt/></p>


![oi](svgs/140c4fc7f4941ce36d531461eecea83c.svg?invert_in_darkmode)
<p align="center"><img src="svgs/cea9b2ff541f7c0eef5d5bf2e9f5e06d.svg?invert_in_darkmode" align=middle width=343.48524705pt height=138.0835962pt/></p>

<p align="center"><img src="svgs/6fd7e9d98ba44eafdfba57e808494e34.svg?invert_in_darkmode" align=middle width=357.31348125pt height=71.00466449999999pt/></p>

<p align="center"><img src="svgs/90fb0d5e5abbeac5741960ea44d7ee53.svg?invert_in_darkmode" align=middle width=365.81203724999995pt height=69.0417981pt/></p>

<!-- <p align="center"><img src="svgs/e45858c011938cbd92291e86b38f0383.svg?invert_in_darkmode" align=middle width=60.913292549999994pt height=29.58934275pt/></p> -->



## Nomenclature

### Variables

<img src="svgs/2b7c31b7df641cd2ffc8154ea6e90540.svg?invert_in_darkmode" align=middle width=30.15119909999999pt height=27.6567522pt/>: Active power injection to HC calculation

<img src="svgs/4c684c9947c8124eb646279e030febe5.svg?invert_in_darkmode" align=middle width=39.27514304999999pt height=27.6567522pt/>: Reactive power injection of DERs dispached by DisCo.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p,&space;q" title="\bg_white p, q" />: Nodal active and reactive power injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;i^{\Re},&space;i^{\Im}" title="\bg_white i^{\Re}, i^{\Im}" />: Real and imaginary part of nodal current injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;v^{\Re},&space;v^{\Im}" title="\bg_white v^{\Re}, v^{\Im}" />: Real and imaginary part of nodal voltage


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Buses' set excluded substation bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

<img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>: Set of operation scenario of DERs' Owner

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios of DG types for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

<img src="svgs/5de3395d9a962facf1228570f1570c3e.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=36.6389529pt/>: DisCO's upper limits of active and reactive power dispached by DERs.

<img src="svgs/5b087afcef448f22d28d062ec207a5bf.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=30.063960299999987pt/>: DisCO's lower limits of active and reactive power dispached by DERs.

<img src="svgs/8a57ec50a9fa4dfedfe3cc701d1153a9.svg?invert_in_darkmode" align=middle width=42.37443869999999pt height=27.6567522pt/>: DERs' power limit.

<img src="svgs/fae5399046b45871e8d75acb5fda8054.svg?invert_in_darkmode" align=middle width=44.18382704999999pt height=27.6567522pt/>: DERs' owner power injection capacity.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{SB}},&space;\overline{Q^{SB}}" title="\bg_white \overline{P^{SB}}, \overline{Q^{SB}}" />: Active and reactive limit of the substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^L" title="\bg_white \mu^L" />: Load scenario multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^{HC}" title="\bg_white \mu^{HC}" />: Scenario multiplier for HC calculation

<img src="svgs/777d440c6c333beeb18498c6d177104f.svg?invert_in_darkmode" align=middle width=41.25197999999999pt height=27.6567522pt/>: DERs' Owner Operation multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;N^B" title="\bg_white N^B" />: Quantity of buses without DGs

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b^{SB}" title="\bg_white b^{SB}" />: Substation's bus

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;b_{d}" title="\bg_white b_{d}" /> : DG's bus

## Roadmap

- [x] Define the model

- [x] Implement the model on JuMP.jl

- [x] High-level interface for HC estimation

- [x] Initial documentation

- [ ] Implement changes on system's topology.

- [ ] Implement tests for power flow calculation using a simple system

- [ ] Describe the relationship between the model and codebase

- [ ] Better Documentation