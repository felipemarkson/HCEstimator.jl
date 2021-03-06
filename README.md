<!-- INPUT FILE TO README FOR readme2tex! -->

# Hosting Capacity Estimator
[![DOI](https://zenodo.org/badge/465498806.svg)](https://zenodo.org/badge/latestdoi/465498806)

This library provides a Distributed Energy Resources' Hosting Capacity estimation of distribution systems considering that the Distribution Company can partially dispatch other DERs installed in the system.

## Citing
If you find HCEstimator useful in your work, we kindly request that you cite it as below

```bibtex
@software{Monteiro_felipemarkson_HCEstimator_jl_v0_0_1_2022,
    author = {Monteiro, Felipe},
    doi = {10.5281/zenodo.6784000},
    license = {MIT},
    month = {6},
    title = {{felipemarkson/HCEstimator.jl: v0.0.1}},
    url = {https://github.com/felipemarkson/HCEstimator.jl},
    version = {0.0.1},
    year = {2022}
}

```
## Getting Started

### Data Format

The ```DistSystem.System``` structure expected a [DataFrames.jl](https://dataframes.juliadata.org/stable/) with the follow columns:
```
Row │ Branch  FB     TB     Type     R_Ohm    X_ohm    Bus     Amp_pu    P_MW        Q_MVAr      Bshunt_MVAr
    │ Int64   Int64  Int64  String   Float64  Float64  Int64   Float64   Float64     Float64     Float64
────┼──────────────────────────────────────────────────────────────────────────────────────────────────
```
The active branches must have "Fixed" in ```Type``` field.

### Dependencies

You will need [Julia](https://julialang.org/) v1.6 or greater, [JuMP.jl](https://jump.dev/)  v0.23 or greater, and a nonlinear solver compatible with [JuMP.jl](https://jump.dev/) and the model described below.

### Exemple of use

This exemple also can be found in [example.jl](example/example.jl).

The distribution system of the example is also available in [Dolatabadi et. al. (2021)](https://ieeexplore.ieee.org/document/9258930).

## Mathematical Model

This library uses the following model:


<img src="svgs/d14abed1a5115037397da740c933f4dc.svg?invert_in_darkmode" align=middle width=35.15994899999999pt height=14.15524440000002pt/> 


<p align="center"><img src="svgs/9440c3753d7bb170f2ba3e904f295d29.svg?invert_in_darkmode" align=middle width=194.91340605pt height=29.58934275pt/></p>

 
<img src="svgs/9dc19dc073dbefeb7f85c0f086c9ec27.svg?invert_in_darkmode" align=middle width=22.009199849999987pt height=20.221802699999984pt/>


<p align="center"><img src="svgs/6257bcc9d6bb1be9fabb2f047b0a15a6.svg?invert_in_darkmode" align=middle width=459.40233405pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/39c4bae6cb3acc2e715d991e0a85dab2.svg?invert_in_darkmode" align=middle width=454.9440225pt height=69.0417981pt/></p>

<p align="center"><img src="svgs/9b30c7275cfd7d1824970757c6dbfadb.svg?invert_in_darkmode" align=middle width=360.06316664999997pt height=118.35736770000001pt/></p>


<p align="center"><img src="svgs/140c4fc7f4941ce36d531461eecea83c.svg?invert_in_darkmode" align=middle width=350.37468345pt height=49.315569599999996pt/></p>

<p align="center"><img src="svgs/cc6ccc5eb6638967bd57b2084c7408c5.svg?invert_in_darkmode" align=middle width=421.12247099999996pt height=118.35736770000001pt/></p>

<p align="center"><img src="svgs/6cf6441e282f47db0b45579b54503b07.svg?invert_in_darkmode" align=middle width=343.48524705pt height=118.35736770000001pt/></p>

<p align="center"><img src="svgs/cdd9c97351d2852cca8d647b0fdfb93b.svg?invert_in_darkmode" align=middle width=438.00400709999997pt height=139.1657751pt/></p>

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

<img src="svgs/444b8fe966ba1acdc573118df429030a.svg?invert_in_darkmode" align=middle width=46.89511529999999pt height=27.91243950000002pt/>:  Real and imaginary current flow


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Load buses without DERs

<img src="svgs/6446d4b13a86884a30a20fc3209b6678.svg?invert_in_darkmode" align=middle width=22.364821049999986pt height=27.6567522pt/>: Set of branches

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

<img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>: Set of all possible combinations of operation of DERs' Owner

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

<img src="svgs/b8bc815b5e9d5177af01fd4d3d3c2f10.svg?invert_in_darkmode" align=middle width=12.85392569999999pt height=22.465723500000017pt/>: Lines' ampacity

<img src="svgs/5201385589993766eea584cd3aa6fa13.svg?invert_in_darkmode" align=middle width=12.92464304999999pt height=22.465723500000017pt/>, <img src="svgs/61e84f854bc6258d4108d08d4c4a0852.svg?invert_in_darkmode" align=middle width=13.29340979999999pt height=22.465723500000017pt/>: Nodal conductance and susceptance

<img src="svgs/d36129378f3e3dd4b3157b9b640cd94e.svg?invert_in_darkmode" align=middle width=42.27444209999999pt height=27.6567522pt/>: Time to  curtailment energy resources  

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

<img src="svgs/a1bcca6b26bdfc2be1eb755a53298c5f.svg?invert_in_darkmode" align=middle width=44.429233199999985pt height=27.6567522pt/>: DERs' energy capacity.

<img src="svgs/5de3395d9a962facf1228570f1570c3e.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=36.6389529pt/>: Upper limits of active and reactive power that can be dispached by DERs.

<img src="svgs/5b087afcef448f22d28d062ec207a5bf.svg?invert_in_darkmode" align=middle width=96.65405474999999pt height=30.063960299999987pt/>: Lower limits of active and reactive power that can be dispached by DERs.

<img src="svgs/8a57ec50a9fa4dfedfe3cc701d1153a9.svg?invert_in_darkmode" align=middle width=42.37443869999999pt height=27.6567522pt/>: DERs' power limit.

<img src="svgs/a2369470b5770634fad738b057fd1609.svg?invert_in_darkmode" align=middle width=41.923553099999985pt height=27.6567522pt/>: Proportion of DERs' power limit that can be dispached by DisCo.

<img src="svgs/09e4e271511208a731624abd23a74597.svg?invert_in_darkmode" align=middle width=41.51258924999999pt height=27.6567522pt/>:  Proportion of  DERs' Energy Capacity that can be used by DisCo.

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
