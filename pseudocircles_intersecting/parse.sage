from ast import literal_eval
from basics import *



def fingerprint_to_vertices(fingerprint):
	vertices_along = {}
	for i in fingerprint:
		assert(i>0)
		vertices_along[i] = []
		for j in fingerprint[i]:
			vertices_along[i].append((i,abs(j)) if j>0 else (abs(j),i))
	return vertices_along


def fingerprint_to_primal_graph(fingerprint):
	vertices_along = fingerprint_to_vertices(fingerprint)
	edges = []
	for i in vertices_along:
		color_i = i 
		for j in range(len(vertices_along[i])):
			edges.append((vertices_along[i][j-1],vertices_along[i][j],color_i))
	return DiGraph(edges) # undirected graph will have multi edges whenever there is a digon 



import argparse
parser = argparse.ArgumentParser()

parser.add_argument("ifp",type=str,help="input file path")
parser.add_argument("--ifpydict",action='store_true', help="each line in input file encodes an arrangement. by default graph6/sparse6 encoding is used. activate this flag for python dict encoding")

args = parser.parse_args()
print("args",args)



ct = 0
for l in open(args.ifp).readlines():
	ct+=1

	if args.ifpydict:
		dual_arcs = literal_eval(l)
	else:
		g_dual = Graph(l)
		dual_arcs = color_graph(g_dual)

	print("Graph #",ct)

	fingerprint = compute_fingerprint(dual_arcs)

	print ("fingerprint:",fingerprint)
	print ("fingerprint to vertices:",fingerprint_to_vertices(fingerprint))
	#exit()

	g_primal = fingerprint_to_primal_graph(fingerprint)
	print ("primal graph:",g_primal.edges())

	# must be 4-regular planar graph 
	assert(set(g_primal.degree()) == {4})
	assert(g_primal.is_planar(set_pos=1)) 

	g_primal.plot(color_by_label=True).save(args.ifp+".arrangement"+str(ct)+".png")