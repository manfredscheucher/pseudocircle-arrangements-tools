# sagemath script to enumerate all arrangements of pairwise intersecting pseudocircles
# author: Manfred Scheucher 2024

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

from itertools import * 
from sys import *
from basics_pseudocircles import *
import datetime

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input",type=str,help="input file")
parser.add_argument("--output","-o",type=str,help="output file")
parser.add_argument("--digonfree",action='store_true',help="restrict to digonfree arrangements")
parser.add_argument("--canonical",action='store_false',help="canonical labeling")
parser.add_argument("--parallel","-P",action='store_true',help="use flag for parallel computations")

args = parser.parse_args()
vargs = vars(args)
print("c\tactive args:",{x:vargs[x] for x in vargs if vargs[x] != None and vargs[x] != False})


line = open(args.input).readline()
line = line.replace("\n","")
print(f"read initial arrangement from first line of {args.input}: {line}")

if args.output:
	print(f"write all arrangements to {args.output}")
	outf = open(args.output,"w")



def handle(line):
	g = Graph(line)
	arcs = color_graph(g)
	g = Graph([(u,v,arcs[(u,v)]) for (u,v) in arcs])
	next_layer = set()
	for h in all_possible_triangle_flips(g,digonfree=args.digonfree):
		if args.canonical: h = h.canonical_label(algorithm="sage")
		fingerprint = h.sparse6_string()
		if fingerprint not in prev_layer:
			next_layer.add(fingerprint)
	return next_layer


if 1:
	layer = 0
	prev_layer = set()
	current_layer = {line}
	total_count = 0
	
	while current_layer:
		total_count += len(current_layer)

		print(f"{datetime.datetime.now()}: layer {layer} / # = {len(current_layer)} / total = {total_count}")

		if args.output:
			for line in current_layer:
				outf.write(line+"\n")

		if args.parallel:
			from multiprocessing import Pool,cpu_count
			result = Pool(cpu_count()).map(handle,current_layer)
		else:
			result = map(handle,current_layer)

		next_layer = set.union(*result)
						
		prev_layer = current_layer
		current_layer = next_layer
		layer += 1

	print("total:",total_count)

