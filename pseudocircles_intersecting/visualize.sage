# Author: Manfred Scheucher 2016-2023
# Note: based on "draw7.sage"


from scipy.spatial import ConvexHull
from sys import argv
from ast import literal_eval
from itertools import combinations
from basics import *


# G might be a multigraph, G2 is simple graph 
def graph_2_ipe(G,G2,filepath):
	points = G.get_pos()

	ipestyle = 'ipestyle.txt'
	g = open(filepath,'w')
	g.write("""<?xml version="1.0"?>
		<!DOCTYPE ipe SYSTEM "ipe.dtd">
		<ipe version="70005" creator="Ipe 7.1.4">
		<info created="D:20150825115823" modified="D:20150825115852"/>
		""")
	with open(ipestyle) as f:
		for l in f.readlines():
			g.write("\t\t"+l)
	g.write("""<page>
		<layer name="alpha"/>
		<layer name="beta"/>
		<view layers="alpha beta" active="alpha"/>\n""")
	
	# normalize
	x0 = min(x for (x,y) in points.values())
	y0 = min(y for (x,y) in points.values())
	x1 = max(1,max(x for (x,y) in points.values())-x0,1)
	y1 = max(1,max(y for (x,y) in points.values())-y0,1)
	maxval = max(x1,y1)
	
	#scale 
	M = 392
	points = {i:(100+float((points[i][0]-x0)*M)/maxval,100+float((points[i][1]-y0)*M)/maxval) for i in points}

	# write faces
	for f in G2.faces():
		if len(f) == 3:
			f = [u for (u,v) in f]
			if f == outer_face: continue 
			x0,y0 = points[f[0]]
			x1,y1 = points[f[1]]
			x2,y2 = points[f[2]]
			g.write('<path layer="beta" fill="lightgray">\n')
			g.write(str(x0)+" "+str(y0)+" m\n")
			g.write(str(x1)+" "+str(y1)+" l\n")
			g.write(str(x2)+" "+str(y2)+" l\n")
			g.write('h\n')
			g.write('</path>\n')

	# write edges
	pseudocirlcle = compute_pseudocircles(G)

	distances = {v:[] for v in G.vertices()}
	for c in pseudocirlcle:
		for i in range(len(pseudocirlcle[c])):
			p0 = x0,y0 = points[pseudocirlcle[c][i-1]]
			p1 = x1,y1 = points[pseudocirlcle[c][i  ]]
			d2 = (x0-x1)^2+(y0-y1)^2
			distances[pseudocirlcle[c][i-1]].append(d2)
			distances[pseudocirlcle[c][i  ]].append(d2)

	for c in pseudocirlcle:
		# B-splines
		g.write('<path layer="alpha" stroke="'+c+'" pen="heavier">\n')
		for i in range(len(pseudocirlcle[c])):
			x0,y0 = points[pseudocirlcle[c][i-2]]
			x1,y1 = points[pseudocirlcle[c][i-1]]
			x2,y2 = points[pseudocirlcle[c][i  ]]
			d0 = (x0-x1)^2+(y0-y1)^2
			d2 = (x2-x1)^2+(y2-y1)^2
			lmbd0 = sqrt(min(distances[pseudocirlcle[c][i-1]])/d0)/3
			lmbd2 = sqrt(min(distances[pseudocirlcle[c][i-1]])/d2)/3
			xl,yl = x1+lmbd0*(x0-x1),y1+lmbd0*(y0-y1)
			xr,yr = x1+lmbd2*(x2-x1),y1+lmbd2*(y2-y1)
			g.write(str(xl)+" "+str(yl)+"\n")
			g.write(str(x1)+" "+str(y1)+"\n")
			g.write(str(xr)+" "+str(yr)+"\n")
		g.write("u\n</path>\n")
		
	print ("pseudocircles:", pseudocirlcle)
	
	g.write("""</page>\n</ipe>""")
	g.close()
	print ("finished ",filepath)



def compute_planar_dual_graph(G,arcs):
	assert(G.is_planar(set_pos=1))
	faces = G.faces()
	dual_edges = []
	checked_edges = {}
	l = len(faces)
	for i in range(l):
		f = faces[i]
		for e in f:
			e = min(e),max(e)
			u,v = e
			if e in checked_edges:
				j = checked_edges[e]
				col = arcs[u,v] if e in arcs else arcs[v,u]
				dual_edges.append((i,j,col))
			else:
				checked_edges[e] = i
	return Graph(dual_edges,multiedges=True)



def tutte_layout(G,outer_face,weights):
	V = G.vertices()
	pos = dict()
	l = len(outer_face)

	a0 = pi/l+pi/2
	for i in range(l):
		ai = a0+pi*2*i/l
		pos[outer_face[i]] = (cos(ai),sin(ai))
	
	n = len(V)
	M = zero_matrix(RR,n,n)
	b = zero_matrix(RR,n,2)

	for i in range(n):
		v = V[i]
		if v in pos:
			M[i,i] = 1
			b[i,0] = pos[v][0]
			b[i,1] = pos[v][1]
		else:
			nv = G.neighbors(v)
			s = 0
			for u in nv:
				j = V.index(u)
				wu = weights[u,v]
				s += wu
				M[i,j] = -wu
			M[i,i] = s

	sol = M.pseudoinverse()*b
	return {V[i]:sol[i] for i in range(n)}



def compute_pseudocircles(G):
	edges = G.edges()
	colors = {c for (_,_,c) in edges}
	edge_with_color = {c0:[(a,b) for (a,b,c) in edges if c == c0] for c0 in colors}

	pseudocirlcle = {}
	for c in colors:
		Gc = Graph(edge_with_color[c])
		print("c",c,edge_with_color[c],"->",Gc.degree())
		assert(set(Gc.degree())=={2})
		sequence = Gc.cycle_basis()
		assert(len(sequence) == 1)
		pseudocirlcle[c] = sequence[0]

	return pseudocirlcle
 



import argparse
parser = argparse.ArgumentParser()
#parser.add_argument("n",type=int,help="number of pseudocircles")
parser.add_argument("fp",type=str,help="input file")
parser.add_argument("--format",default="ipe",choices=["ipe","pdf","png"],help="format of visualization")
parser.add_argument("--multiple_views",action='store_true',help="visualize more than one view")
parser.add_argument("--all_views",action='store_true',help="visualize all views")
parser.add_argument("--add_text",action='store_true',help="add text")

args = parser.parse_args()
vargs = vars(args)
print("c\tactive args:",{x:vargs[x] for x in vargs if vargs[x] != None and vargs[x] != False})



ct = 0
for l in open(args.fp).readlines():
	ct+=1
	g = Graph(l)
	arcs = color_graph(g)

	print(80*"-")
	print("Graph #",ct)

	fingerprint = compute_fingerprint(arcs)
	print ("fingerprint:")
	print (fingerprint_to_string(fingerprint))
	
	G_dual = Graph([(u,v,arcs[(u,v)]) for u,v in arcs])
	G_dual_fingerprint = G_dual.canonical_label(algorithm="sage").sparse6_string()
	deg = G_dual.degree()
	vec = tuple(deg.count(i) for i in range(max(deg)+1))
	print ("dual_vec",vec)

	# compute primal graph 
	G = compute_planar_dual_graph(G_dual,arcs) 
	print ("edges",G.edges(labels=0))

	m = max(max(a) for a in arcs)+1
	vertices = range(m)
	ci = common_intersection(vertices,arcs)

	
	G2 = Graph(G.edges(),multiedges=False) # remove multi edges
	assert(G2.is_planar(set_pos=1))

	colors = list(set(c for (a,b,c) in G2.edges()))
	n = len(colors)

	known_graphs = set()

	candidates = []
	maxsym = 0

	# select candidates for the outer cell
	for outer_face in G2.faces():
		outer_face = [e[0] for e in outer_face]

		this_graph = Graph(G2)
		for v in outer_face: 
			this_graph.add_edge((-1-v,v))

		sym = this_graph.automorphism_group().order()
		if not args.all_views:
			if sym < maxsym: continue
			if sym > maxsym:
				maxsym = sym
				candidates = []

		gstr = this_graph.canonical_label().sparse6_string()
		if gstr in known_graphs: continue
		known_graphs.add(gstr)

		candidates.append(outer_face)


	print ("maxsym:",maxsym)

	ct2 = 0
	for outer_face in candidates:
		# compute iterated tutte embeddings for fixed outer cell

		ct2 += 1	
		
		if args.multiple_views and ct2 > 1: break

		weights = dict()
		for u,v in G.edges(labels=None):
			weights[u,v] = weights[v,u] = 0.000001

		F = G2.faces() 
		F = [tuple(e[0] for e in f) for f in F]

		eps = 0.1
		maxit = 100
		mypoly = lambda x: x^2
		for it in range(1,maxit+1):
			if it > 1:
				weights_old = weights
				weights = dict()
				for (u,v) in G.edges(labels=None):
					weights[u,v] = weights[v,u] = (RR(weights_old[u,v]+eps*(mypoly(dist2(u,v))-weights_old[u,v])))

				pos = G2.get_pos()
				for f in G2.faces():
					vol_f = ConvexHull([pos[v] for u,v in f]).volume
					qf = RR(vol_f)
					for u,v in f:
						weights[u,v] += float(it*qf)^4
						weights[v,u] += float(it*qf)^4

				vw0 = vector([weights_old[e] for e in G.edges(labels=False)]).normalized()
				vw1 = vector([weights[e] for e in G.edges(labels=False)]).normalized()
				dvw = (vw0-vw1).norm()
				if dvw < 10^-10: break
						
			G2.set_pos(tutte_layout(G2,outer_face,weights))
			pos = G2.get_pos()
			dist2 = lambda u,v: (pos[u][0]-pos[v][0])^2+(pos[u][1]-pos[v][1])^2


		G.set_pos(G2.get_pos())
		plotfile = f"{args.fp}.vis{ct}_{ct2}.{args.format}"
		
		if args.format == 'ipe':
			graph_2_ipe(G,G2,plotfile)	

		elif args.format in ['png','pdf']:
			objects = []
			p = G.get_pos()
			
			pseudocirlcle = compute_pseudocircles(G)
			print ("PC",pseudocirlcle)

			distances = {v:[] for v in G.vertices()}
			for c in pseudocirlcle:
				for i in range(len(pseudocirlcle[c])):
					p0 = x0,y0 = p[pseudocirlcle[c][i-1]]
					p1 = x1,y1 = p[pseudocirlcle[c][i  ]]
					d2 = (x0-x1)^2+(y0-y1)^2
					distances[pseudocirlcle[c][i-1]].append(d2)

			for c in pseudocirlcle:
				for i in range(len(pseudocirlcle[c])):
					p0 = x0,y0 = p[pseudocirlcle[c][i-2]]
					p1 = x1,y1 = p[pseudocirlcle[c][i-1]]
					p2 = x2,y2 = p[pseudocirlcle[c][i  ]]
					pl = xl,yl = (x1+x0)/2.,(y1+y0)/2.
					pr = xr,yr = (x1+x2)/2.,(y1+y2)/2.

					objects.append(bezier_path([[pl,p1,pr]]))

			pl = sum(objects)
			if args.add_text:
				pl += text(plotfile,(0,max(y for (x,y) in p.values())+0.035))
			pl.axes(show=False)
			pl.save(plotfile,figsize=10)		
		
		else:
			exit(f"invalid format: {format}")
