<!-- INPUT FILE TO README FOR readme2tex! -->

# Hosting Capacity Estimator

This library provides a Distributed Energy Resources' Hosting Capacity estimation of distribution systems considering that the Distribution Company can partially dispatch other DERs installed in the system.

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


$\text{max.        }$ 


$$
\text{Hosting Capacity}
\begin{cases}
N^B p^{HC}
\end{cases}
$$

 
$\text{s.t.        }$


$$
\begin{matrix}
\text{Power injection}\\
\text{in buses without DERs}
\end{matrix}
\begin{cases}
p_{blks} =  \mu^{HC}_{s}p^{HC} - \mu^L_lP^L_ b\\ 
q_{blks} = - \mu^L_lQ^L_ b\\
\forall b \in \overline{\Omega}, \forall l \in L, \forall d \in D, \forall k \in K,\forall s \in S
\end{cases}
$$

$$
\begin{matrix}
\text{Power injection}\\
\text{in buses with DERs}
\end{matrix}
\begin{cases}
p_{blks} = \mu^{DER}_{dk}P^{DER}_{d} + p^{DER}_{dlks} - \mu^L_lP^L_ b\\ 
q_{blks} = q^{DER}_{dlk} - \mu^L_lQ^L_ b\\
\forall d \in D, \forall b \in \{b_d\}, \forall l \in L,  \forall k \in K, \forall s \in S
\end{cases}
$$

$$
\begin{matrix}
\text{Power, voltage }\\
\text{and current}\\
\text{relationship}
\end{matrix}
\begin{cases}
p_{blks} = v^{\Re}_{blks}i^{\Re}_{blks} + v^{\Im}_{blks}i^{\Im}_{blks}\\ 
q_{blks} = v^{\Im}_{blks}i^{\Re}_{blks} - v^{\Re}_{blks}i^{\Im}_{blks}\\
i^{\Re}_{blks} = \sum_{j \in \Omega} G_{bj}v^{\Re}_{jlks} - B_{bj}v^{\Im}_{jlks}\\
i^{\Im}_{blks} = \sum_{j \in \Omega} B_{bj}v^{\Re}_{jlks} + G_{bj}v^{\Im}_{jlks}\\
\forall b \in \Omega, \forall l \in L, \forall k \in K, \forall s \in S
\end{cases}
$$


$$
\text{Voltage limits}
\begin{cases}
(\underline{V})^2\leq(v^{\Re}_{blks})^2 + (v^{\Im}_{blks})^2 \leq (\overline{V})^2\\
\forall b \in \Omega, \forall l \in L,\forall k \in K, \forall s \in S
\end{cases}
$$

$$
\text{Lines limits}
\begin{cases}
f_{ij}^{\Re} = (v^{\Re}_{ilks} - v^{\Re}_{jlks})G_{ij} - (v^{\Im}_{ilks} - v^{\Im}_{jlks})B_ {ij}\\
f_{ij}^{\Im} = (v^{\Im}_{ilks} - v^{\Im}_{jlks})G_{ij} + (v^{\Re}_{ilks} - v^{\Re}_{jlks})B_ {ij}\\
(f_{ij}^{\Re})^2 + (f_{ij}^{\Im})^2 \leq (F_{ij})^2\\
-F_{ij} \leq f_{ij}^{\Re}, f_{ij}^{\Im} \leq F_{ij}\\
\forall (i,j) \in \Omega^{B}, \forall l \in L,\forall k \in K, \forall s \in S
\end{cases}
$$

$$\begin{matrix}
\text{Substation}\\
\text{constraints}\\
\end{matrix}
\begin{cases}
v^{\Im}_{blks} = 0\\
0 \leq p_{blks} \leq \overline{P^{SB}}\\
0 \leq q_{blks} \leq \overline{Q^{SB}}\\
(i^{\Re}_{blks})^2 + (i^{\Im}_{blks})^2 \geq 0\\
\forall b \in \{b^{SB}\}, \forall l \in L,\forall k \in K, \forall s \in S
\end{cases}
$$

$$
\text{DERs limits}
\begin{cases}
-\beta^{DER}_dE^{DER}_{d}\leq p^{DER}_{dlks}T^{CUR} \leq \beta^{DER}_dE^{DER}_d\\
\underline{P}^{DER}_{d}\leq p^{DER}_{dlks} \leq \overline{P}^{DER}_d\\
\underline{Q}^{DER}_{d}\leq q^{DER}_{dlks} \leq \overline{Q}^{DER}_{d}\\
(p^{DER}_{dlks})^2 + (q^{DER}_{dlks})^2 \leq (\alpha_d^{DER} S^{DER}_{d})^2\\
(\mu^{DER}_{dk} P^{DER}_{d} + p^{DER}_{dlks})^2 + (q^{DER}_{dlks})^2 \leq (S^{DER}_{d})^2\\
\forall d \in D, \forall l \in L, \forall k \in K,\forall s \in S
\end{cases}
$$

$$\begin{matrix}
\text{Power, voltage }\\
\text{and current}\\
\text{constraints}
\end{matrix}
\begin{cases}
-M \leq p_{blks}, q_{blks}, i^{\Re}_{blks}, i^{\Im}_{blks}\leq M\\
-\overline{V}\leq v^{\Re}_{blks}, v^{\Im}_{blks} \leq \overline{V}\\
\forall b \in \Omega, \forall l \in L,\forall k \in K,\forall s \in S
\end{cases}
$$

<!-- $$
\text{Costs}
\begin{cases}
\large?
\end{cases}
$$ -->



## Nomenclature

### Variables

$p^{HC}$: Active power injection to HC calculation

$p^{DER}$: Active power injection of DERs dispached by DisCo.

$q^{DER}$: Reactive power injection of DERs dispached by DisCo.

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;p,&space;q" title="\bg_white p, q" />: Nodal active and reactive power injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;i^{\Re},&space;i^{\Im}" title="\bg_white i^{\Re}, i^{\Im}" />: Real and imaginary part of nodal current injection

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;v^{\Re},&space;v^{\Im}" title="\bg_white v^{\Re}, v^{\Im}" />: Real and imaginary part of nodal voltage

$f^{\Re}, f^{\Im}$:  Real and imaginary current flow


### Sets

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\Omega" title="\bg_white \Omega" />: Buses' set

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{\Omega}" title="\bg_white \overline{\Omega}" />: Load buses without DERs

$\Omega^B$: Set of branches

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;L" title="\bg_white L" />: Set of load scenarios

$K$: Set of all possible combinations of operation of DERs' Owner

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;S" title="\bg_white S" />: Set of scenarios for HC calculation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;D" title="\bg_white D" />: Set of DisCo's DGs

### Parameters

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\underline{V},&space;\overline{V}" title="\bg_white \underline{V}, \overline{V}" />: Lower and upper voltage limits

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;V^{SB}" title="\bg_white V^{SB}" />: Substation's voltage

$F$: Lines' ampacity

$G$, $B$: Nodal conductance and susceptance

$T^{CUR}$: Time to  curtailment energy resources  

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;M" title="\bg_white M" />: A big number

$E^{DER}$: DERs' energy capacity.

$\overline{P}^{DER}, \overline{Q}^{DER}$: Upper limits of active and reactive power that can be dispached by DERs.

$\underline{P}^{DER}, \underline{Q}^{DER}$: Lower limits of active and reactive power that can be dispached by DERs.

$S^{DER}$: DERs' power limit.

$\alpha^{DER}$: Proportion of DERs' power limit that can be dispached by DisCo.

$\beta^{DER}$:  Proportion of  DERs' Energy Capacity that can be used by DisCo.

$P^{DER}$: DERs' owner power injection capacity. $P^{DER} = (1 - \alpha^{DER})S^{DER}$

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\overline{P^{SB}},&space;\overline{Q^{SB}}" title="\bg_white \overline{P^{SB}}, \overline{Q^{SB}}" />: Active and reactive limit of the substation

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^L" title="\bg_white \mu^L" />: Load scenario multiplier

<img src="https://latex.codecogs.com/svg.image?\bg_white&space;\mu^{HC}" title="\bg_white \mu^{HC}" />: Scenario multiplier for HC calculation

$\mu^{DER}$: DERs' Owner Operation scenario

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