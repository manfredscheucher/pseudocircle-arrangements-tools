# description

This is a visuation script for digonfree arrangements of pairwise intersecting pseudocircles
as described in our article (https://link.springer.com/article/10.1007/s00454-020-00173-4)[Arrangements of Pseudocircles: Triangles and Drawings].

Install (https://www.sagemath.org/)[SageMath] to run the scripts.

You can download the database of digonfree intersecting arrangements for up to 7 pseudocircles from the 
(https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=pseudocircles)[Homepage of Pseudocircles],
encoded in mod1s6 format. For details on the encoding see
(https://www3.math.tu-berlin.de/diskremath/pseudocircles/?show=information)[this page]. 

To visualize all digonfree arrangements of 4 pseudocircles, run for example
'''
sage visualize.sage example_data/all4_digonfree.enc
'''
The program by default creates an (https://ipe.otfried.org/)[IPE] file, but can also create PDF or PNG.
