#import "@preview/ilm:1.4.1": *
#import "@preview/fletcher:0.5.8" as fletcher: *

#set text(lang: "en")

#show: ilm.with(
  title: [Research project report:\ Modelling MAPK/ERK pathway using Ordinary Differential Equations],
  author: "Przemysław Pilipczuk",
  date: datetime(year: 2025, month: 10, day: 13),
  abstract: [
    Abstract text
  ],
  preface: [
    #align(center + horizon)[
      Preface text
    ]
  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= Abstract
The MAPK/ERK pathway serves a key role in determining fate of a cell from extracellular inputs. 
Different cell fates are linked to a dynamics of the final node in the cascade, `ERK` kinases. 
To understand how different dynamc patterns of their behavior arise, 
we attempt to mechanistically model the simplified version of this pathway using Ordinary Differential Equations.
Using data from a fibroblast cell transfected with optoRTK constructs and stimulated with various patterns of light, 
we attempted to estimated model parameters based on these experiments and use cross-validation techniques to 
check for generalization. Resulting fits had problems with achieving several performance metrics that would singify 
an optimal solution. 

= Introduction
TODO

= Methods & Materials

== Experimental Data
Data used for fitting the model was obtained from an experimental setup consisting of fibroblast cells 
transfected with an optoEGFR construct (optogenetic actuator) and being stimulated with various patterns of light.
Data from 3 experiments were used in our pipeline, representing distinct light activation patterns. 
All experiments start with a 10 minute period of no actication, that we use for calibrating the baseline levels of activity.\
First pattern that was investigated was a transient actuvation pulse for a given amount of time. 
The experiment was repeated with different durations, namely
$t = {0, 50, 100, 200, 500, 1000}$ ms. This experiment was used during development for
testing and verifying due to its simplicity.
#figure(
  image("static/singlecel_transient_data.png"),
  caption: [Single cell ERK-KTR activity in transient activation experiment. Each black curve represents a trajectory of a single cell. Red line is a median of all trajectories.]
)
Second pattern that was incorporated was sustained activation. In this experiment,
stimulation was started and sustained for a 140 minutes with three different power settings.
#figure(
  stack(
    dir:ltr,
    spacing: 2mm,
    image("static/singlecell_sustained_weak.png",width:33%),
    image("static/singlecell_sustained_medium.png",width:33%),
    image("static/singlecell_sustained_strong.png",width:33%),
  ),
  caption: [Single cell ERK-KTR activity in sustained activation experiment. \
  Each black curve is a single cell trajectory of ERK-KTR, red line describes median.]
)

Third pattern incorporated into the pipeline was a ramp pattern. This pattern starts by
running a light pulse every minute, and increasing the pulse widht with every subsequent actication,
starting from 0 and ending at 700ms pulse width, resulting in overall ramp shape of the activation curve over time.

#figure(
  image("static/singlecell_ramp.png"),
  caption: [Single cell ERK-KTR activity in sustained activation experiment. \
  Each black curve is a single cell trajectory of ERK-KTR, red line describes median.]
)

The development and initial testing of modeling pipeline was done using only transient activation experiment. 
Sustained and Ramp were incorporated as a means of providing cross-validation for the fitting process.

== The chosen model

Finding the brlance between simplicity and accuracy is the key problem in model definition. 
Too simple, and the results are not meaningful in real life ....
Too complex, and we risk overfitting, parameter non-identifiability, and fragility towards biased data

#import "@preview/fletcher:0.5.8": diagram, node, edge

#diagram(
  // layout (left→right flow)
  spacing: 4.5em,

  // --- nodes (give each a name so we can reference it in edges)
  node((0, 0), [Light],  name: <light>),
  node((0, 1), [RAS],    name: <ras>),
  node((2, 0), [RAS_s],  name: <ras_s>),

  node((3, 0), [RAF_s],  name: <raf_s>),
  node((3,-1), [RAF],    name: <raf>),

  node((4, 0), [MEK_s],  name: <mek_s>),
  node((4,-1), [MEK],    name: <mek>),

  node((5, 0), [ERK_s],  name: <erk_s>),
  node((5,-1), [ERK],    name: <erk>),

  node((6, 0), [NFB_s],  name: <nfb_s>),
  node((6,-1), [NFB],    name: <nfb>),

  // --- activation edges (positive terms)
  edge(<light>,  <ras_s>, "-|>", [ light · RAS/(K12+RAS) ]),
  edge(<ras_s>,  <raf_s>, "-|>", [ k34 · RAS_s · RAF/(K34+RAF) ]),
  edge(<raf_s>,  <mek_s>, "-|>", [ k56 · RAF_s · MEK/(K56+MEK) ]),
  edge(<mek_s>,  <erk_s>, "-|>", [ k78 · MEK_s · ERK/(K78+ERK) ]),
  edge(<erk_s>,  <nfb_s>, "-|>", [ f12 · ERK_s · NFB/(F12+NFB) ]),

  // --- feedback from NFB_s to RAF_s (appears in RAF_s ODE as − knfb·NFB_s · ... )
  edge(<nfb_s>, <raf_s>, "-|>", [ feedback (−knfb·NFB_s) ], bend: -25deg),

  // --- deactivation / export terms (negative terms to unphosphorylated pools)
  edge(<ras_s>, <ras>, "-|>", [ −k21 · RAS_s/(K21+RAS_s) ], bend: 25deg),
  edge(<raf_s>, <raf>, "-|>", [ −k43 · RAF_s/(K43+RAF_s)   ], bend: 25deg),
  edge(<mek_s>, <mek>, "-|>", [ −k65 · MEK_s/(K65+MEK_s)   ], bend: 25deg),
  edge(<erk_s>, <erk>, "-|>", [ −k87 · ERK_s/(K87+ERK_s)   ], bend: 25deg),
  edge(<nfb_s>, <nfb>, "-|>", [ −f21 · NFB_s/(F21+NFB_s)   ], bend: 25deg),

  // optional: small global styling tweaks
  edge-stroke: 0.9pt,
  node-stroke: 0.9pt,
  label-size: 9pt,
)


== Ordinary Differential Equations

Ordinary differential equations is a mathemathical framework for describing the change of one variable
(dependant variable, here Y) over another variable (independent variable, here X). 
Its simplest formulation is an expression that equates some mathematical expression to a
derivative of our variable in question over the independent variable. $ frac(d Y,d X) = ... $ 
A solution to a differential equation is usually understood as obtaining a $Y(X)$ form, also called an _general solution_.
General solutions can be obtained using an analytical solving process, the difficulty of which is heavily 
dependant on the specifc problem being solved. An often encountered problem with analytical solution approach 
is a problem that contains complex, nonlinearly coupled equations, which do not yield easily to this method. 
An alternative approach to solving a system that has these characteristics is a numerical one.
This method relies on a provided initial conditions and a `X-step` resolution to simulate a single trajectory within
an ODE system by evaluating the equations sequentially at a consecutive `X-steps` away from the provided starting point.
This method, while providing a weaker form of solution, can deal with harder problems,
including those that describe complex, nonlinear systems.

== Modeling & Simulation pipeline

Model definition was done in symbolic form using SymPy in python (TODO: reference them), as a list of symbolic differential equations.
The same tool was also used to lower the symbolic expression down to a numerical representation (`lambdify` function).
A constructed model consists of a set of differential equations and parameter values.
An effort was made to make this pipeline model-and-experiment agnostic and have low friction for implementing new models.
This effort led to an architecture where each new model needs only to fulfill a simple interface for defining 
its equations and parameters, and each new experiment needs to define its own pattern of input and a 
parsing function for the data it generated. \
An interactive environment for simulating behavior and exploring perturbations to parameters 
was constructed using marimo notebooks. \
Parameter estimation was done using tools from SciPy library, 
namely `minimize` and `solve_ivp` to optimize loss function and to solve a numerical system respectively. 
The general scheme involved minimizing residual sum of squares for the data given in an experiment across all the groups in a given experiment.


= Results 

= Discussion

== Time resolution trouble
During implementation of the parameter estimation regime, a technical difficulty was encountered. 
The experiments had been replicated multiple times with different parameter values for light stimulation,
usually differing in stimulation time of a pulse of light, with values ranging from 50ms to 2000ms.
At the same time, data for those experiments was collected with a rate of one sample per minute.
Such difference in time ranges between sampling and input means that our experimental 
data will never be able to differentiate between the light stimulation duration groups 
within an experiment just by looking at the data 
(we would need to increase the sampling rate 1200 times to be able to discern signals that lasted 50ms,
the most fine-grained light signal in our experimental data).
To circumvent this problem, two solutions were contemplated.
1. An interpolation algorithm could have been used to synthetically create data points of the sampling rate we desire. This forces our new data points to inherit our assumptions about how the data is interpolated, which could introduce a systematic bias (as example, for linearity).
2. A proxy metric for a total light energy of a light pulse for a datapoint is introduced instead of a "binary" baseline. This allows for more flexibility but at a cost of having to create a realistically-scaling function that works for all kinds of experiments and across different levels of magnitude of light stimulation duration.

After theoretical evaluation of pros and const of both, a second solution strategy was picked, due to a better compatibility with the goal of having short training times. 
 
= Conclusions

= Future work

= Supplementary material
