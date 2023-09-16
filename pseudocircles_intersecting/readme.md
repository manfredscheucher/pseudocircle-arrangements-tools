# information

This repository provides some functionality and tools 
to work with arrangements of pairwise intersecting pseudocircles. 
These tool have proved to be very useful in our past research:

1. [Arrangements of Pseudocircles: Triangles and Drawings](http://doi.org/10.1007/s00454-020-00173-4)
2. [Arrangements of Pseudocircles: On Circularizability](http://doi.org/10.1007/s00454-019-00077-y)
3. [Coloring Circle Arrangements: New 4-Vertex-Critical Planar Graphs](http://arxiv.org/abs/2205.08181)
4. [Arrangements of Pseudocircles: On Digons and Triangles](http://arxiv.org/abs/2208.12110)
5. [Flip Graphs for Arrangements of Pseudocircles](https://page.math.tu-berlin.de/~scheuch/publ/forsv-fgap-eurocg23.pdf)

Also in:
6. [The unavoidable arrangements of pseudocircles](https://arxiv.org/abs/1805.10957)

We plan to make more functionality and 
the more general framework for general arrangements of pseudocircles 
available in the future. 
However, due to limited time-resources of the author
this might take some while.
Please contact me if you need something that 
might already implemented but is not available yet here.



# visualization

The 'visualize.sage' script allows to visualize arrangements of pairwise intersecting pseudocircles
 described in our article [Arrangements of Pseudocircles: Triangles and Drawings](https://link.springer.com/article/10.1007/s00454-020-00173-4).

Install [SageMath](https://www.sagemath.org/) to run the scripts.

You can download the database of all intersecting arrangements for up to 6 pseudocircles 
and all digonfree intersecting arrangements for up to 7 pseudocircles from the 
[Homepage of Pseudocircles](https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=pseudocircles),
encoded in mod1s6 format. For details on the encoding see
[this page](https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=information). 

For example, to visualize all digonfree arrangements of 4 pseudocircles, run for example
'''
sage visualize.sage example_data/all4.mod1s6
'''
The program by default creates an [IPE](https://ipe.otfried.org/) file, but can also create PDF or PNG.


# enumeration

Starting with one intersecting arrangement on n pseudocircles, 
one can use the 'enum_flipgraph.sage' program.
This approach is feasible as the flip graph of intersecting arrangements is connected;
our article 
[Flip Graphs for Arrangements of Pseudocircles](https://page.math.tu-berlin.de/~scheuch/publ/forsv-fgap-eurocg23.pdf) 
is submitted; contact one of the authors for a draft.

For example, one can run 
'''
head -1 example_data/all5.mod1s6 > X && sage enum_flipgraph.sage X
'''
to enumerate all intersecting arrangements on 5.
