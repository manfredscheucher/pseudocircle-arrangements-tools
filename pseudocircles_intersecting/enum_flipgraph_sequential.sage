# sagemath script to enumerate all arrangements of pairwise intersecting pseudocircles
# author: Manfred Scheucher 2024

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

from itertools import * 
from sys import *
from basics_pseudocircles import *
import datetime
import os


import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input",type=str,help="input file")
parser.add_argument("output",type=str,help="output file")
parser.add_argument("--layer","-l",type=int,default=None,help="layer")
#parser.add_argument("--splitoutput","-so",action='store_true',help="split output, one file for each layer")
parser.add_argument("--digonfree",action='store_true',help="restrict to digonfree arrangements")
parser.add_argument("--canonical",action='store_false',help="canonical labeling")
parser.add_argument("--parallel","-p",action='store_true',help="compute in parallel")
parser.add_argument("--chunks","-c",type=int,default=1000,help="compute in chunks")

args = parser.parse_args()
vargs = vars(args)
#print("c\tactive args:",{x:vargs[x] for x in vargs if vargs[x] != None and vargs[x] != False})

args.splitoutput = True

layer = args.layer
if layer == None:
	line = open(args.input).readline()
	line = line.replace("\n","")
	print(f"read initial arrangement from first line of {args.input}: {line}")

	next_layer = {line}
	next_fp = f"{args.output}.{0}"
	print(f"write {len(next_layer)} layer {0} arrangements to {next_fp}")
	outf = open(next_fp,"w")

	for line in next_layer:
		outf.write(line+"\n")
		outf.flush()

	outf.close()

	layer = 0
	total_count = 0
	
	start_time = datetime.datetime.now()

	while True:
		layer_fp = f"{args.output}.{layer}"
		if not os.path.exists(layer_fp): break

		current_count = len(open(layer_fp).readlines())
		total_count += current_count

		now_time = datetime.datetime.now()
		print(f"{now_time} / {now_time-start_time}: layer {layer} / # = {current_count} / total = {total_count}")

		script = argv[0].replace(".sage.py",".sage")
		cmd = f"sage {script} {args.input} {args.output} --layer {layer}"
		if args.parallel: cmd += " --parallel"
		if args.chunks: cmd += f" --chunks {args.chunks}"
		print(f"start processing layer {layer}: {cmd}")

		next_fp = f"{args.output}.{layer+1}"
		assert(not os.path.exists(next_fp))
		stdout.flush()

		os.system(cmd)
		print(40*"*")

		layer += 1
		
	print("total:",total_count)
	print("done.")
	exit()



def handle(line):
	g = Graph(line)
	arcs = color_graph(g)
	g = Graph([(u,v,arcs[(u,v)]) for (u,v) in arcs])
	next_layer = set()
	for h in all_possible_triangle_flips(g,digonfree=args.digonfree):
		if args.canonical: h = h.canonical_label(algorithm="sage")
		fingerprint = h.sparse6_string()
		if fingerprint not in prev_layer and fingerprint not in current_layer:
			next_layer.add(fingerprint)
	return next_layer


def chunks(L,k): # split large arrays into chunks of size k
	c = []
	for x in L:
		c.append(x)
		if len(c) == k: 
			yield c
			c = []
	if c: 
		yield c


import psutil # for memory usage profiling, install with "sage --pip psutil"
import gc # garbage collector to keep memory usage as low as possible




if 1:
	assert(layer >= 0) 
	#print(20*"=","layer",layer,20*"=")
	if layer == 0:
		prev_layer = set()
		print(f"layer {layer}: no previous layer")
	else:
		prev_fp = f"{args.output}.{layer-1}"
		prev_layer = {l.replace("\n","") for l in open(prev_fp).readlines()}
		print(f"layer {layer}: read {len(prev_layer)} from prev file {prev_fp}")
		assert(prev_layer)

	current_fp = f"{args.output}.{layer}"
	current_layer = {l.replace("\n","") for l in open(current_fp).readlines()}
	print(f"layer {layer}: read {len(current_layer)} from current file {current_fp}")
	assert(current_layer)

	assert(not (current_layer&prev_layer)) # disjoint sets

	if args.parallel:
		from multiprocessing import Pool,cpu_count
		print(f"layer {layer}: use {cpu_count()} cores for parallelization")
		pool = Pool(cpu_count())

	if 1:
		if not args.chunks:
			result = pool.map(handle,current_layer) if args.parallel else map(handle,current_layer)
			next_layer = set.union(*result)
		else:
			next_layer = set()
			for c in chunks(current_layer,args.chunks):
				#print("chunk of size",len(c))
				result = pool.map(handle,c) if args.parallel else map(handle,c)
				next_layer = next_layer.union(*result)

		#mem_usageGB = round(psutil.virtual_memory()[3]/10^9,3)
		mem_usageGB = round(psutil.Process(os.getpid()).memory_info().rss/10^9,6)
		mem_usageperc = psutil.virtual_memory()[2]
		print(f"layer {layer}: mem_usage = {mem_usageGB}GB / OS memory {mem_usageperc}%")

		if next_layer:
			next_fp = f"{args.output}.{layer+1}"
			print(f"layer {layer}: write {len(next_layer)} layer-{layer+1} arrangements to {next_fp}")
			outf = open(next_fp,"w")

			for line in next_layer:
				outf.write(line+"\n")
				outf.flush()

			outf.close()
