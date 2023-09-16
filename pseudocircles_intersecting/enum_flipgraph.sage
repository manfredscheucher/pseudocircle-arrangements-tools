from itertools import * 
from sys import *
from basics_pseudocircles import *


import argparse
parser = argparse.ArgumentParser()
parser.add_argument("fp",type=str,help="input file")
parser.add_argument("--digonfree",action='store_true',help="restrict to digonfree arrangements")
parser.add_argument("--canonical",action='store_false',help="canonical labeling")

args = parser.parse_args()
vargs = vars(args)
print("c\tactive args:",{x:vargs[x] for x in vargs if vargs[x] != None and vargs[x] != False})



line = open(args.fp).readline()
line = line.replace("\n","")
#G0 = Graph(line)
#E = G.edges(labels=0)


def compute_flipgraph(line):
	#line = Graph(line).canonical_label(algorithm="bliss").sparse6_string()
	layer = 0
	prev_layer = set()
	current_layer = {line}
	total_count = 0

	while current_layer:
		#if layer > 5: break
		layer += 1
		total_count += len(current_layer)

		print("layer",layer,":",len(current_layer),"/",total_count,"/",len(current_layer)+len(prev_layer))	

		next_layer = set()
		for line in current_layer:
			g = Graph(line)
			arcs = color_graph(g)
			g = Graph([(u,v,arcs[(u,v)]) for (u,v) in arcs])

			for h in all_possible_triangle_flips(g,digonfree=args.digonfree):
				if args.canonical: h = h.canonical_label(algorithm="sage")
				fingerprint = h.sparse6_string()
				if fingerprint not in prev_layer and fingerprint not in next_layer:
					next_layer.add(fingerprint)
						
		prev_layer = current_layer
		current_layer = next_layer

	print("total:",total_count)


if 1:
	compute_flipgraph(line)
	
else:
	import cProfile
	with cProfile.Profile() as pr:
		compute_flipgraph(line)
	prof_path = 'file.prof'
	pr.dump_stats(prof_path) # pyprof2calltree -i file.prof && kcachegrind file.prof.log
	print("wrote profile to:",prof_path)