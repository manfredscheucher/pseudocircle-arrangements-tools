# sagemath script to enumerate all arrangements of pairwise intersecting pseudocircles
# author: Manfred Scheucher 2024

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

from itertools import * 
from sys import *
from basics_pseudocircles import *

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input",type=str,help="input file")
parser.add_argument("--output","-o",type=str,help="output file")
parser.add_argument("--digonfree",action='store_true',help="restrict to digonfree arrangements")
parser.add_argument("--canonical",action='store_false',help="canonical labeling")

args = parser.parse_args()
vargs = vars(args)
print("c\tactive args:",{x:vargs[x] for x in vargs if vargs[x] != None and vargs[x] != False})


line = open(args.input).readline()
line = line.replace("\n","")
print(f"read initial arrangement from first line of {args.input}: {line}")

if args.output:
	print(f"write all arrangements to {args.output}")
	outf = open(args.output,"w")

if 1:
	layer = 0
	prev_layer = set()
	current_layer = {line}
	total_count = 0
	
	while current_layer:
		layer += 1
		total_count += len(current_layer)

		print(f"layer {layer},\tcurrent # = {len(current_layer)},\ttotal # = {total_count}")

		if args.output:
			for line in current_layer:
				outf.write(line+"\n")

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

