# information

this repository provides some tools to work with pseudocircles.


# visualization

The 'visualize.sage' script allows to visualize arrangements of pairwise intersecting pseudocircles
 described in our article (https://link.springer.com/article/10.1007/s00454-020-00173-4)[Arrangements of Pseudocircles: Triangles and Drawings].

Install (https://www.sagemath.org/)[SageMath] to run the scripts.

You can download the database of all intersecting arrangements for up to 6 pseudocircles 
and all digonfree intersecting arrangements for up to 7 pseudocircles from the 
(https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=pseudocircles)[Homepage of Pseudocircles],
encoded in mod1s6 format. For details on the encoding see
(https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=information)[this page]. 

For example, to visualize all digonfree arrangements of 4 pseudocircles, run for example
'''
sage visualize.sage example_data/all4.mod1s6
'''
The program by default creates an (https://ipe.otfried.org/)[IPE] file, but can also create PDF or PNG.


# enumeration

Starting with one intersecting arrangement on n pseudocircles, 
one can use the 'enum_flipgraph.sage' program.
This approach is feasible as the flip graph of intersecting arrangements is connected;
our article (https://page.math.tu-berlin.de/~scheuch/publ/forsv-fgap-eurocg23.pdf)[Flip Graphs for Arrangements of Pseudocircles] is submitted; contact one of the authors for a draft.

For example, one can run 
'''
head -1 example_data/all5.mod1s6 > X && sage enum_flipgraph.sage X
'''
to enumerate all intersecting arrangements on 5.
